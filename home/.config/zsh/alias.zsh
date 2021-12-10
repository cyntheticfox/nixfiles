#!/usr/bin/env zsh

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

# alias bat for cat if available
if command -v bat &>/dev/null; then
    alias cat="bat"
fi

# alias htop for top if available
if command -v htop &>/dev/null; then
    alias top="htop"
fi

# alias procs for ps if available
if command -v procs &>/dev/null; then
    alias ps="procs"
fi

# Set additional aliases for ls
alias la="ls -abghl"
alias dir="la"
alias l="ls"

# Set clearing alias
alias cls="clear"

# Set coloring for gcc and clang
if command -v gcc &>/dev/null; then
    alias gcc="gcc -fdiagnostics-color"
fi

if command -v clang &>/dev/null; then
    alias clang="clang -fcolor-diagnostics"
fi

# Add aliases for nix flakes
alias n="nix"
alias nb="nix build"
alias nf="nix flake"
alias nfc="nix flake check"
alias nfi="nix flake init"
alias nfl"nix flake lock"
alias nfu="nix flake update"
alias nfsw="sudo nixos-rebuild switch --flake ."
alias nr="nix run"
alias ns="nix search"
alias nsn="nix search nixpkgs"
