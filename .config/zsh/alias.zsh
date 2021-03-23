# alias.zsh
#
# A collection of bash aliases

# Set aliases depending on the editor
case $EDITOR in
"nvim")
    alias vim="nvim"
    alias vi="nvim"
    alias edit="nvim"
    ;;
"vim")
    alias vi="vim"
    alias edit="vim"
    ;;
*)
    alias vim="vi"
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
