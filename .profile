# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# Export XDG variables
if [ -n $XDG_CONFIG_HOME ]; then
    export XDG_CONFIG_HOME="$HOME/.config"
elif [ -n $XDG_CONFIG_DIRS ]; then
    export XDG_CONFIG_DIRS="$HOME/.config:$XDG_CONFIG_DIRS"
fi

if [ -n $XDG_DATA_HOME ]; then
    export XDG_DATA_HOME="$HOME/.local/share"
elif [ -n $XDG_DATA_DIRS ]; then
    export XDG_DATA_DIRS="$HOME/.local/share:$XDG_DATA_DIRS"
fi

if [ -n $XDG_CACHE_DIR ]; then
    export XDG_CACHE_DIR="$HOME/.cache"
fi

if [ -n $XDG_RUNTIME_DIR ]; then
    export XDG_RUNTIME_DIR="$HOME/tmp"
fi

# Set editor
if command -v nvim &>/dev/null; then
    export EDITOR="nvim"
    export VISUAL="nvim -R"
elif command -v vim &>/dev/null; then
    export EDITOR="vim"
    export VISUAL="vim -R"
else
    export EDITOR="vi"
    export VISUAL="vi -R"
fi

# Set email
export EMAIL="houstdav000@gmail.com"

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

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

# Added by Nix installer
if [ -e /home/david/.nix-profile/etc/profile.d/nix.sh ]; then
    . /home/david/.nix-profile/etc/profile.d/nix.sh;
fi
