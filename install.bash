#!/bin/env bash
#
# Installation script

NERD_TAG="v2.1.0"
NERD_FONTS="CascadiaCode FiraCode Hack Hasklig Terminus"

FONTS_DIR="${HOME}/.local/share/fonts"
DL_OUT="FONT"

function check_command() {
    if ! command -v "$1" &>/dev/null; then
        echo "$1 not installed. Exiting..."
        exit 1
    fi
}

function create_if_nd() {
    if [[ ! -d "$1" ]]; then
        mkdir -p "$1"
    fi
}

function copy_if_ne() {
    if [[ ! -f "$1" ]]; then
        cp "$1" "${HOME}/$1"
    else
        echo "${HOME}/$1 exists, not replacing"
    fi
}
export -f copy_if_ne

check_command curl
check_command unzip
check_command mktemp

TEMP_DIR="$(mktemp -d)"

find . \
    -type f \
    -not -name '.git*' \
    -not -name 'install.sh' \
    -not -name 'README.md' \
    -not -name 'LICENSE' \
    -not -name 'flake*' \
    -exec bash -c "copy_if_ne" "{}" \;

# Create fonts dir if it does not exist
create_if_nd "${FONTS_DIR}/ttf"
create_if_nd "${FONTS_DIR}/otf"

# Dowload and install fonts
for NERD_FONT in ${NERD_FONTS}; do
    mkdir -p "${TEMP_DIR}"
    curl -Lo "${TEMP_DIR}/${DL_OUT}" "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_TAG}/${NERD_FONT}.zip"
    unzip "${TEMP_DIR}/${DL_OUT}.zip"

    # Remove Windows-compatible fonts (we don't need them on Linux)
    rm ./*Windows*

    cp ./*.ttf "${FONTS_DIR}/ttf"
    cp ./*.otf "${FONTS_DIR}/otf"
done
