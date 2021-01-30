#!/bin/sh
#
# Installation script

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
