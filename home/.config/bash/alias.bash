#!/usr/bin/env bash

# Set aliases depending on the editor
case $EDITOR in
"nvim")
    alias v="nvim"
    alias edit="nvim"
    ;;
"vim")
    alias v="vim"
    alias edit="vim"
    ;;
*)
    alias v="vi"
    alias edit="vi"
    ;;
esac

case $VISUAL in
"nvim -R")
    alias view="nvim -R"
    ;;
"vim -R")
    alias view="vim -R"
    ;;
*)
    alias view="vi -R"
    ;;
esac

# alias ls if exa is available
if command -v exa &>/dev/null; then
    alias ls="exa -F --color=always --icons"
else
    alias ls="ls -F --color=always"
fi

# Set additional aliases for ls
alias la="ls -abghl"
alias dir="la"

# Set clearing alias
alias cls="clear"

# Set coloring for gcc and clang
if command -v gcc &>/dev/null; then
    alias gcc="gcc -fdiagnostics-color"
fi

if command -v clang &>/dev/null; then
    alias clang="clang -fcolor-diagnostics"
fi
