#!/usr/bin/env bash

LOCKFILE="flake.lock"
NIX_BIN="nix"
JQ_BIN="jq"
CURL_BIN="curl"
JQ_SCRIPT_FILE="scripts/unparse-flake-inputs.jq"

GENERAL_FLAGS=(
    "--accept-flake-config"
    "--no-warn-dirty"
)

# TODO: Waiting on https://github.com/NixOS/nix/issues/6453#issuecomment-1518117282 to ignore custom outputs
# TODO: Waiting on https://github.com/NixOS/nix/issues/7230 for hiding saved value use
FLAKE_CHECK_FLAGS=(
    "${GENERAL_FLAGS[@]}"
    "--no-update-lock-file"
    "--no-write-lock-file"
    "--no-use-registries"
)

CHECK_UPDATE_CMD="$CURL_BIN --location --silent"
UPDATE_INPUT_CMD="$NIX_BIN flake lock ${GENERAL_FLAGS[*]}"
EVAL_CHECK_CMD="$NIX_BIN flake check --no-build ${FLAKE_CHECK_FLAGS[*]}"
BUILD_CHECK_CMD="$NIX_BIN flake check ${FLAKE_CHECK_FLAGS[*]}"

if [ ! -e "$LOCKFILE" ]; then
    echo "Cannot find \"$LOCKFILE\" in current directory"
    exit 1
fi

INPUTS=$($JQ_BIN -r -f "$JQ_SCRIPT_FILE" "$LOCKFILE")

PASS=()
NONE=()
FAIL=()

# NOTE: No point in making this parallel as Nix will just complain... I think
for INPUT in $INPUTS; do
    IFS=';' read -ra INPUT_ARRAY <<<"$INPUT"

    INPUT_NAME="${INPUT_ARRAY[0]}"
    INPUT_HASH="${INPUT_ARRAY[1]}"
    INPUT_TYPE="${INPUT_ARRAY[2]}"
    INPUT_URL="${INPUT_ARRAY[3]}"
    FOUND_HASH=""

    echo "Checking for available update for \"$INPUT_NAME\""

    if [[ $INPUT_TYPE == "github" ]]; then
        RESPONSE=$($CHECK_UPDATE_CMD -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "$INPUT_URL")

        # Pretty sure this is how to do it...
        # shellcheck disable=SC2181
        if [[ $? -ne 0 ]]; then
            echo "Unable to check input \"$INPUT_NAME\". Possible rate limiting?"

            FAIL+=("$INPUT_NAME: Resolution failed")

            continue
        fi

        FOUND_HASH=$(echo "$RESPONSE" | jq '.sha' -r)

        if [[ $FOUND_HASH == "$INPUT_HASH" ]]; then
            echo "No update available for \"$INPUT_NAME\""

            NONE+=("$INPUT_NAME")

            continue
        fi
    elif [[ $INPUT_TYPE == "gitlab" ]]; then
        RESPONSE=$($CHECK_UPDATE_CMD "$INPUT_URL")

        # shellcheck disable=SC2181
        if [[ $? -ne 0 ]]; then
            echo "Unable to check input \"$INPUT_NAME\". Possible rate limiting?"

            FAIL+=("$INPUT_NAME: Resolution failed")

            continue
        fi

        FOUND_HASH=$(echo "$RESPONSE" | jq '.id' -r)

        if [[ $FOUND_HASH == "$INPUT_HASH" ]]; then
            echo "No update available for \"$INPUT_NAME\""

            PASS+=("$INPUT_NAME")

            continue
        fi
    fi

    ORIGINAL_FLAKE=$(<$LOCKFILE)

    echo "Attempting to update \"$INPUT_NAME\""

    if ! $UPDATE_INPUT_CMD --update-input "$INPUT_NAME" "${NIX_FLAKE_FLAGS[@]}"; then
        echo "Unable to update input \"$INPUT_NAME\""
        echo "$ORIGINAL_FLAKE" >$LOCKFILE

        FAIL+=("$INPUT_NAME: Update failed")

        continue
    fi

    echo "Testing eval for \"$INPUT_NAME\""

    if ! $EVAL_CHECK_CMD; then
        echo "Check eval for updated input \"$INPUT_NAME\" failed."
        echo "$ORIGINAL_FLAKE" >$LOCKFILE

        FAIL+=("$INPUT_NAME: Check eval failed")

        continue
    fi

    echo "Testing build for \"$INPUT_NAME\""

    if ! $BUILD_CHECK_CMD; then
        echo "Check build for updated input \"$INPUT_NAME\" failed."
        echo "$ORIGINAL_FLAKE" >$LOCKFILE

        FAIL+=("$INPUT_NAME: Check build failed")

        continue
    fi

    PASS+=("$INPUT_NAME")
done

cat <<EOF

=================
Update flake script completed.

${#NONE[@]} inputs had no updates:
$(printf '%s\n' "${NONE[@]}")

${#PASS[@]} inputs successfully updated:
$(printf '%s\n' "${PASS[@]}")

${#FAIL[@]} inputs failed to update:
$(printf '%s\n' "${FAIL[@]}")

=================
EOF
