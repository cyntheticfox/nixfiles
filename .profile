# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.

umask 022

# Helper functions
create_dir_if_nonexistent() {
    if [[ ! -d "$1" ]]; then
        mkdir -p "$1"
        return 0
    else
        return 1
    fi
}

test_set_var() {
    if [[ -z "${!1}" ]]; then
        create_dir_if_nonexistent "$2"
        export "$1"="$2"
        return 0
    else
        return 1
    fi
}

append_var() {
    if [[ -d "$2" && ":${!1}:" != *":$2:"* ]]; then
        export "$1"="${!1}:$2"
        return 0
    else
        return 1
    fi
}

append_path() {
    return append_var "PATH" "$1"
}

test_append_var() {
    if [[ -z "${!1}" ]]; then
        create_dir_if_nonexistent "$3"
        export "$1"="$3"
        return 0
    elif [[ -z "${!2}" ]]; then
        create_dir_if_nonexistent "$3"
        append_var "$2" "$3"
        return 0
    else
        return 1
    fi
}

# Apply variable functions
if [[ -n "$HOME" ]]; then
    # Added by Nix installer
    if [[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh";
    fi

    # Export XDG variables
    test_append_var "XDG_CONFIG_HOME" "XDG_CONFIG_DIRS" "$HOME/.config"

    test_append_var "XDG_DATA_HOME" "XDG_DATA_DIRS" "$HOME/.local/share"

    test_set_var "XDG_CACHE_DIR" "$HOME/.cache"

    test_set_var "XDG_RUNTIME_DIR" "$HOME/tmp"

    # set PATH so it includes user's private bin if it exists
    if [ -d "$HOME/bin" ]; then
        append_path "$HOME/bin"
    fi

    # set PATH so it includes user's private bin if it exists
    if [ -d "$HOME/.local/bin" ]; then
        append_path "$HOME/.local/bin"
    fi

    # set PATH to include cargo bin if it exists
    if [ -d "$HOME/.cargo/bin" ]; then
        append_path "$HOME/.cargo/bin"
    fi
fi

# Set TERMINFO_DIRS if not set
if [[ -z "$TERMINFO_DIRS" && -d "/lib/terminfo" ]]; then
    export TERMINFO_DIRS="/lib/terminfo"
fi

# Set terminal
if command -v termite &> /dev/null; then
    export TERM="xterm-termite"
elif command -v alacritty &> /dev/null; then
    export TERM="alacritty"
else
    echo "No known terminal found"
fi

# Set editor
if command -v nvim &> /dev/null; then
    export EDITOR="nvim"
    export VISUAL="nvim -R"
elif command -v vim &> /dev/null; then
    export EDITOR="vim"
    export VISUAL="vim -R"
elif command -v vi &> /dev/null; then
    export EDITOR="vi"
    export VISUAL="vi -R"
else
    echo "VI family not found"
fi

# Set browser
if command -v firefox &> /dev/null; then
    export BROWSER="firefox"
elif command -v chromium &> /dev/null; then
    export BROWSER="chromium"
elif command -v w3m &> /dev/null; then
    export BROWSER="w3m"
else
    echo "Firefox, Chromium, and W3M not available"
fi

# Set email
export EMAIL="houstdav000@gmail.com"

#=============================================================================#
# Steal man page highlighting from
#  https://github.com/lilyinstarlight/dotfiles/blob/master/.profile
#
# The MIT License (MIT)
#
# Copyright (c) 2017, Foster McLane <fkmclane@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
#   of this software and associated documentation files (the "Software"), to
#   deal in the Software without restriction, including without limitation the
#   rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
#   sell copies of the Software, and to permit persons to whom the Software is
#   furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
#   all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
#   DEALINGS IN THE SOFTWARE.

export LESS_TERMCAP_mb=$'\e[01;31m'
export LESS_TERMCAP_md=$'\e[01;34m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;31m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[01;32m'

#=============================================================================#
