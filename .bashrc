if [[ $- == *i* ]]; then
    if command -v fish &> /dev/null; then
        exec fish
    elif command -v zsh &> /dev/null; then
        exec zsh
    else
        echo "Neither fish nor zsh exist"

        if [ -d "$XDG_CONFIG_HOME/bash" ]; then
            source "$XDG_CONFIG_HOME/bash/config.bash"
        fi
    fi
fi
