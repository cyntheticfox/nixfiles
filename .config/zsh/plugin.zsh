# Install antigen if not present
if [[ ! -f "$XDG_CONFIG_HOME/zsh/antigen.zsh" ]]; then
    curl -L git.io/antigen > "$XDG_CONFIG_HOME/zsh/antigen.zsh"
fi

# Source installed antigen
source "$XDG_CONFIG_HOME/zsh/antigen.zsh"

# Configure Oh-My-Zsh
antigen use oh-my-zsh

# Oh-My-Zsh plugins
antigen bundle git
antigen bundle command-not-found
antigen bundle rust

# Apply antigen config
antigen apply
