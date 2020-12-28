if [[ $- == *i* && "$SHLVL" == "1" ]]; then

    # Run other shells if available
    if command -v fish &> /dev/null; then
        exec fish
    elif command -v zsh &> /dev/null; then
        exec zsh
    else
        echo "Neither fish nor zsh exist"

        # Run bash startup files in .config
        if [[ -d "$XDG_CONFIG_HOME/bash" ]]; then
            source "$XDG_CONFIG_HOME/bash/config.bash"
        fi
    fi
elif [[ $- == *i* ]]; then
    if [[ -d "$XDG_CONFIG_HOME/bash" ]]; then
        source "$XDG_CONFIG_HOME/bash/config.bash"
    fi
fi
