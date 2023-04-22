#!/usr/bin/env bash

LOCKFILE="flake.lock"
NIX_BIN="nix"
GENERAL_FLAGS=(
  "--accept-flake-config"
  "--no-warn-dirty"
)
FLAKE_CHECK_FLAGS=(
  "${GENERAL_FLAGS[@]}"
  "--no-update-lock-file"
  "--no-write-lock-file"
  "--no-use-registries"
)
UPDATE_INPUT_CMD="$NIX_BIN flake lock ${GENERAL_FLAGS[*]}"
EVAL_CHECK_CMD="$NIX_BIN flake check --no-build ${FLAKE_CHECK_FLAGS[*]}"
BUILD_CHECK_CMD="$NIX_BIN flake check ${FLAKE_CHECK_FLAGS[*]}"

if [ ! -e "$LOCKFILE" ]; then
  echo "Cannot find \"$LOCKFILE\" in current directory"
  exit 1
fi

get_inputs() {
  jq '.nodes.root.inputs | keys | .[]' "$LOCKFILE" | tr '\n' ' '
}

INPUTS=$(get_inputs | tr -d '"')

PASS=()
FAIL=()

# NOTE: No point in making this parallel as Nix will just complain
for INPUT in $INPUTS; do
  ORIGINAL_FLAKE=$(<$LOCKFILE)

  echo "Attempting to update \"$INPUT\""
  if ! $UPDATE_INPUT_CMD --update-input "$INPUT" "${NIX_FLAKE_FLAGS[@]}"; then
    echo "Unable to update input \"$INPUT\""
    echo "$ORIGINAL_FLAKE" >$LOCKFILE
    FAIL+=("$INPUT")

    continue
  fi

  echo "Testing eval for \"$INPUT\""
  if ! $EVAL_CHECK_CMD; then
    echo "Check eval for updated input \"$INPUT\" failed."
    echo "$ORIGINAL_FLAKE" >$LOCKFILE

    FAIL+=("$INPUT: Check eval failed")

    continue
  fi

  echo "Testing build for \"$INPUT\""
  if ! $BUILD_CHECK_CMD; then
    echo "Check build for updated input \"$INPUT\" failed."
    echo "$ORIGINAL_FLAKE" >$LOCKFILE

    FAIL+=("$INPUT: Check build failed")

    continue
  fi

  PASS+=("$INPUT")
done

cat << EOF

=================
Update flake script completed.

${#PASS[@]} inputs successfully updated:
$(printf '%s\n' "${PASS[@]}")

${#FAIL[@]} inputs failed to update:
$(printf '%s\n' "${FAIL[@]}")

=================
EOF

