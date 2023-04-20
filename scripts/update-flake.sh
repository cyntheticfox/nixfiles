#!/usr/bin/env bash

LOCKFILE="flake.lock"

if [ ! -e "$LOCKFILE" ]; then
  echo "Cannot find \"$LOCKFILE\" in current directory"
  exit 1
fi

get_inputs() {
  jq '.nodes.root.inputs | keys | .[]' "$LOCKFILE" | tr '\n' ' '
}

INPUTS=$(get_inputs | tr -d '"')

PASS=""
FAIL=""

# NOTE: No point in making this parallel as Nix will just complain
for INPUT in $INPUTS; do
  ORIGINAL_FLAKE=$(<$LOCKFILE)

  if ! nix flake lock --update-input "$INPUT"; then
    echo "Unable to update input \"$INPUT\""
    echo "$ORIGINAL_FLAKE" >$LOCKFILE
    FAIL="$FAIL $INPUT"

    continue
  fi

  if ! nix flake check; then
    echo "Check for updated input \"$INPUT\" failed."
    echo "$ORIGINAL_FLAKE" >$LOCKFILE
    FAIL="$FAIL $INPUT"

    continue
  fi

  PASS="$PASS $INPUT"
done

cat << EOF

=================
Update flake script completed.

$(echo "$PASS" | wc -w) inputs successfully updated:
$(echo "$PASS" | tr ' ' "\n")

$(echo "$FAIL" | wc -w) inputs failed to update:
$(echo "$FAIL" | tr ' ' "\n")

=================
EOF

