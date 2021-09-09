#!/usr/bin/env bash
#
# Installation script

NERD_TAG="v2.1.0"
NERD_FONTS="CascadiaCode FiraCode Hack Hasklig Terminus"

DOTFILES_DIR="./home"

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

function install_nerdfonts() {
    local TEMP_DIR
    local FONTS_DIR
    local DL_OUT

    TEMP_DIR="$(mktemp -d)"
    FONTS_DIR="${HOME}/.local/share/fonts"
    DL_OUT="FONT"
    check_command curl
    check_command unzip
    check_command mktemp

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
}

export -f copy_if_ne

find "${DOTFILES_DIR}" \
    -type f \
    -exec bash -c "copy_if_ne" "{}" \;

install_nerdfonts
