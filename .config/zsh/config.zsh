# Configure ZSH Options
# Cd options
setopt AUTO_CD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# History Options
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt APPEND_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS

# Completion options
setopt ALWAYS_TO_END
setopt AUTO_MENU
setopt COMPLETE_IN_WORD
setopt FLOW_CONTROL

# Export History variables
export HISTFILE="${HOME}/.zsh_history"
export HISTSIZE=102400
export SAVEHIST=10240

# Load plugins
if [[ -f "$XDG_CONFIG_HOME/zsh/plugin.zsh" ]]; then
    source "$XDG_CONFIG_HOME/zsh/plugin.zsh"
fi

# Bring in ZSH aliases
if [[ -f "$XDG_CONFIG_HOME/zsh/alias.zsh" ]]; then
    source "$XDG_CONFIG_HOME/zsh/alias.zsh"
fi

# Use personal functions
if [[ -f "$XDG_CONFIG_HOME/zsh/functions.zsh" ]]; then
    source "$XDG_CONFIG_HOME/zsh/functions.zsh"
fi

# Load Starship
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# Hook direnv
if command -v direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
fi
