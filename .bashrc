if [[ "${SHLVL}" == "1" || (\
    "${SHLVL}" == "2" && -n "${TMUX}") || (\
    "${XDG_SESSION_DESKTOP}" == "gnome" && (\
    "${SHLVL}" == "2" || (\
    "${SHLVL}" == "3" && -n "${TMUX}"))) ]]; then

    # Run other shells if available
    if command -v zsh &>/dev/null; then
        exec zsh
    elif command -v fish &>/dev/null; then
        exec fish
    else
        echo "Neither fish nor zsh exist"

        # Run bash startup files in .config
        if [[ -d "${XDG_CONFIG_HOME}/bash" ]]; then
            # shellcheck source=./.config/bash/config.bash
            source "${XDG_CONFIG_HOME}/bash/config.bash"
        fi
    fi
else
    if [[ -d "${XDG_CONFIG_HOME}/bash" ]]; then
        # shellcheck source=./.config/bash/config.bash
        source "${XDG_CONFIG_HOME}/bash/config.bash"
    fi
fi
