# alias.sh
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

# alias ls if exa is available
if command -v exa &>/dev/null; then
    alias ls="exa -F --color=always"
else
    alias ls="ls -F --color=always"
fi

# Set additional aliases for ls
alias la="ls -abghl"
alias dir="la"

# Set clearing alias
alias cls="clear"
