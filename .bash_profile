# ~/.bash_profile

# Source environment variables from .profile
if [ -f "$HOME/.profile" ]; then
    . $HOME/.profile
fi

# Turn on lesspipe if available
if command -v lesspipe &> /dev/null; then
    eval "$(SHELL=/bin/sh lesspipe)"
fi

source ~/.bashrc
