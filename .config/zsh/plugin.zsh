# install Zplug if not present
if ! command -v git &>/dev/null; then
    echo "git not found"
    exit 1
fi

LS=""
if ! command -v exa &>/dev/null; then
    LS="ls -F --color=always"
else
    LS="exa -F --color=always --icons"
fi


export ZPLUG_HOME="${XDG_CONFIG_HOME}/zsh/zplug"

if [[ ! -d $ZPLUG_HOME ]]; then
    git clone "https://github.com/zplug/zplug" "${ZPLUG_HOME}"
fi

# shellcheck source=~/.config/zsh/zplug
source ${ZPLUG_HOME}/init.zsh

# Source omz plugins
zplug "plugins/archlinux", from:"oh-my-zsh", if:"echo ${OS} | grep 'Arch|Manjaro'"
zplug "plugins/cargo", from:"oh-my-zsh"
zplug "plugins/command-not-found", from:"oh-my-zsh"
zplug "plugins/dnf", from:"oh-my-zsh", if "echo ${OS} | grep 'Fedora'"
zplug "plugins/docker", from:"oh-my-zsh"
zplug "plugins/git", from:"oh-my-zsh"
zplug "plugins/git-flow", from:"oh-my-zsh"
zplug "plugins/git-lfs", from:"oh-my-zsh"
zplug "plugins/golang", from:"oh-my-zsh"
zplug "plugins/kubectl", from:"oh-my-zsh"
zplug "plugins/python", from:"oh-my-zsh"
zplug "plugins/rust", from:"oh-my-zsh"
zplug "plugins/systemadmin", from:"oh-my-zsh"
zplug "plugins/systemd", from:"oh-my-zsh"
zplug "plugins/terraform", from:"oh-my-zsh"
zplug "plugins/ubuntu", from:"oh-my-zsh", if:"echo ${OS} | grep 'Ubuntu'"
zplug "plugins/yum", from:"oh-my-zsh", if "echo ${OS} | grep 'Red Hat|CentOS'"

# Load and set autosuggestion options
zplug "zsh-users/zsh-autosuggestions"
export ZSH_AUTOSUGGEST_STRATEGY=("history" "completion")
export ZSH_AUTOSUGGEST_USE_ASYNC="1"
export ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *"

# Load zsh-users plugins
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# Add extra plugins
zplug "desyncr/auto-ls"
AUTO_LS_COMMANDS=("echo" "${LS}")


zplug "djui/alias-tips", from:"github"
zplug "mafredi/zsh-async", from:"github", use:"async.zsh"
zplug "MichaelAquilina/zsh-auto-notify"


# Add local zsh plugins
zplug "${HOME}/.zsh", from:local

if ! zplug check; then
    zplug install
fi

zplug load
