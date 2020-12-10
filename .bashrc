if [[ $- == *i* ]]; then

    # Added by Nix installer
    if [[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh";
    fi

    # Run other shells if available
    if command -v fish &> /dev/null; then
        exec fish
    elif command -v zsh &> /dev/null; then
        exec zsh
    else
        echo "Neither fish nor zsh exist"

        # Run bash startup files in .config
        if [ -d "$XDG_CONFIG_HOME/bash" ]; then
            source "$XDG_CONFIG_HOME/bash/config.bash"
        fi
    fi
fi
