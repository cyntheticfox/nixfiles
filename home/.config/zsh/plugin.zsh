#!/usr/bin/env zsh
# install Zplug if not present
if ! command -v git &>/dev/null; then
    echo "git not found"
    exit 1
fi

export ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [[ ! -d "$ZINIT_HOME" ]]; then
    git clone "https://github.com/zdharma-continuum/zinit" "$ZINIT_HOME"
fi

# shellcheck source=~/.local/share/zinit/zinit.git/zinit.zsh
source ${ZINIT_HOME}/zinit.zsh

# Source omz snippets
zinit snippet OMZP::cargo
zinit snippet OMZP::command-not-found
zinit snippet OMZP::git
zinit snippet OMZP::git-flow
zinit snippet OMZP::git-lfs
zinit snippet OMZP::golang
zinit snippet OMZP::kubectl
zinit snippet OMZP::python
zinit snippet OMZP::systemadmin
zinit snippet OMZP::terraform

# Load and set autosuggestion options
zinit wait lucid for \
    light-mode zsh-users/zsh-autosuggestions
export ZSH_AUTOSUGGEST_STRATEGY=("history" "completion")
export ZSH_AUTOSUGGEST_USE_ASYNC="1"
export ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *"

# Load zsh-users plugins
zinit for \
    light-mode zsh-users/zsh-completions \
    light-mode zdharma-continuum/fast-syntax-highlighting \
               zdharma-continuum/history-search-multi-word

# Add extra plugins
zinit wait lucid for \
    light-mode MichaelAquilina/zsh-you-should-use \
    light-mode eendroroy/zed-zsh

zinit wait lucid atload"zicompinit; zicdreplay" blockf for \
    zsh-users/zsh-completions
