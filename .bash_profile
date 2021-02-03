# ~/.bash_profile

# Source environment variables from .profile
if [[ -f "$HOME/.profile" ]]; then
    . "$HOME/.profile"
fi

# Turn on lesspipe if available
if command -v lesspipe &> /dev/null; then
    eval "$(SHELL=/bin/sh lesspipe)"
fi

# Run gnome-keyring daemon if available
if command -v gnome-keyring-daemon &> /dev/null; then
    export $(gnome-keyring-daemon --start --components=pkcs11\,secrets\,ssh)
fi

# Run .bashrc if interactive
if [[ $- == *i* && -f "$HOME/.bashrc" ]]; then
    . "$HOME/.bashrc"
fi
