#!/usr/bin/env bash

LOCKFILE="flake.lock"
NIX_FLAKE_CHECK="nix flake check --no-update-lock-file --no-write-lock-file --no-use-registries"

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
  if ! nix flake lock --update-input "$INPUT"; then
    echo "Unable to update input \"$INPUT\""
    echo "$ORIGINAL_FLAKE" >$LOCKFILE
    FAIL+=("$INPUT")

    continue
  fi

  echo "Testing eval for \"$INPUT\""
  if ! $NIX_FLAKE_CHECK --no-build; then
    echo "Check eval for updated input \"$INPUT\" failed."
    echo "$ORIGINAL_FLAKE" >$LOCKFILE

    FAIL+=("$INPUT: Check eval failed")

    continue
  fi

  echo "Testing build for \"$INPUT\""
  if ! $NIX_FLAKE_CHECK; then
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

