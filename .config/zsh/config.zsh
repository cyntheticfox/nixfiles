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
