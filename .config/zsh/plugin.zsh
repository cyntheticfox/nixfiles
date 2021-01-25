# install Zplug if not present
if ! command -v git &> /dev/null; then
    echo "git not found"
    exit 1
fi

export ZPLUG_HOME="$XDG_CONFIG_HOME/zsh/zplug"

if [[ ! -d $ZPLUG_HOME ]]; then
    git clone https://github.com/zplug/zplug $ZPLUG_HOME
fi

source $ZPLUG_HOME/init.zsh

# Source omz plugins
zplug "plugins/archlinux", from:oh-my-zsh
zplug "plugins/command-not-found", from:oh-my-zsh
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/rust", from:oh-my-zsh

# Load zsh-users plugins
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-syntax-highlighting", defer:2

if ! zplug check; then
    zplug install
fi

zplug load
