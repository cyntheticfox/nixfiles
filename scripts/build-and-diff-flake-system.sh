#!/usr/bin/env bash

GITROOT=$(git rev-parse --show-toplevel)
SYSTEM=${2:-$(hostname)}
NIXROOT='/nix'

SYSTEM_MANAGER=''
PROFILE_PATH=''

if command -v nixos-rebuild &>/dev/null; then
    SYSTEM_MANAGER='nixos-rebuild'
    PROFILE_PATH="$NIXROOT/var/nix/profiles/system"
else
    SYSTEM_MANAGER='home-manager'
    PROFILE_PATH="$HOME/.nix-profile"
fi

$SYSTEM_MANAGER build --flake "$GITROOT#$SYSTEM"

nix store diff-closures "$PROFILE_PATH" "$GITROOT/result"
