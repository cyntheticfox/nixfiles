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

# NOTE: No point in making this parallel as Nix will just complain
for INPUT in $INPUTS; do
  ORIGINAL_FLAKE=$(<$LOCKFILE)

  if ! nix flake lock --update-input "$INPUT"; then
    echo "Unable to update input \"$INPUT\""

    echo "$ORIGINAL_FLAKE" >$LOCKFILE
  fi

  if ! nix flake check; then
    echo "Check for updated input \"$INPUT\" failed."

    echo "$ORIGINAL_FLAKE" >$LOCKFILE
  fi
done
