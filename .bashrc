if [[ "$SHLVL" == "1" ]]; then

    # Run other shells if available
    if command -v zsh &> /dev/null; then
        exec zsh
    elif command -v fish &> /dev/null; then
        exec fish
    else
        echo "Neither fish nor zsh exist"

        # Run bash startup files in .config
        if [[ -d "$XDG_CONFIG_HOME/bash" ]]; then
            source "$XDG_CONFIG_HOME/bash/config.bash"
        fi
    fi
else
    if [[ -d "$XDG_CONFIG_HOME/bash" ]]; then
        source "$XDG_CONFIG_HOME/bash/config.bash"
    fi
fi
