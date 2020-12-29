# Install oh-my-zsh if not present
if [[ ! -d "$XDG_CONFIG_HOME/zsh/oh-my-zsh" ]]; then
    export ZSH="$XDG_CONFIG_HOME/zsh/oh-my-zsh"
    export KEEP_ZSHRC="yes"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Configure Oh-My-Zsh
export ZSH="$XDG_CONFIG_HOME/zsh/oh-my-zsh"
ZSH_THEME=""
DISABLE_UPDATE_PROMPT=true
plugins=(
    command-not-found
    git
    rust
)
source $ZSH/oh-my-zsh.sh

# Bring in ZSH aliases
if [[ -f "$XDG_CONFIG_HOME/zsh/alias.zsh" ]]; then
    source "$XDG_CONFIG_HOME/zsh/alias.zsh"
fi

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
