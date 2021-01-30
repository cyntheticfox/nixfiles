#!/bin/env sh
#
# Installation script

if ! command -v curl &> /dev/null; then
    echo "Curl not installed. Exiting..."
    exit 1
fi

if ! command -v unzip &> /dev/null; then
    echo "Unzip not installed. Exiting..."
    exit 1
fi

for line in $(find . -name '.git*' -prune \
    -o -name 'install.sh' -prune \
    -o -name 'README.md' -prune \
    -o -name 'LICENSE' -prune \
    -o -type f -print); do
    if [ -e "$HOME/$line"]; then
        echo "$HOME/$line exists, not replacing"
    else
        cp $line "$HOME/$line"
    fi
done

# Download fonts
NERD_TAG="v2.1.0"
NERD_FONTS="CascadiaCode FiraCode Hack Hasklig Terminus"

FONTS_DIR="$HOME/.local/share/fonts"
FONTS_DL_DIR="/tmp/install_fonts"

# Create fonts dir if it does not exist
if [[ ! -d "$FONTS_DIR/ttf" ]]; then
    mkdir -p "$FONTS_DIR/ttf"
fi

if [[ ! -d "$FONTS_DIR/otf" ]]; then
    mkdir -p "$FONTS_DIR/otf"
fi

# Dowload and install fonts
for NERD_FONT in $NERD_FONTS; do
    mkdir -p $FONTS_DL_DIR
    pushd $FONTS_DL_DIR
    curl -LO "https://github.com/ryanoasis/nerd-fonts/releases/download/$NERD_TAG/$NERD_FONT.zip"
    unzip "$NERD_FONT.zip"

    rm *Windows*
    cp *.ttf $FONTS_DIR/ttf
    cp *.otf $FONTS_DIR/otf
    popd
done
