#!/usr/local/bin/fish
# Set PROFILE variable for powershell-like referencing of this file
set -U profile ~/.config/fish/config.fish
set -U -x SH "fish"

# Set NIXOS_CONFIG variable for quick config changes in nixos
if test -e /etc/nixos/configuration.nix
    set -U NIXOS_CONFIG /etc/nixos/configuration.nix
end

# Turn off greeting message
set -U fish_greeting ""

# Create Alias for vim
alias vim="nvim"

# Create Alias for dir
alias dir="la"

# Create Alias for cls
alias cls="clear"

# Install fisher if available
if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
end

# Edit path
for each in ~/.cargo/bin \
        ~/.nix-profile/bin \
        ~/.local/bin
    if test -d $each
        and not contains $each $PATH
        set -a PATH $each
    end
end

# Set up starship
if test -x ~/.cargo/bin/starship \
        -o -x /etc/profiles/per-user/$USER/bin/starship \
        -o -x ~/.nix-profile/bin/starship
    starship init fish | source
end

# Set up exa
if test -x ~/.cargo/bin/exa \
        -o -x /etc/profiles/per-user/$USER/bin/exa \
        -o -x ~/.nix-profile/bin/exa
    alias exa='exa -F'
    alias ls=exa
    alias la='exa -abghl'
    alias dir='exa -abghl'
end

# Set up bat
if test -x ~/.cargo/bin/bat \
        -o -x /etc/profiles/per-user/$USER/bin/bat \
        -o -x ~/.nix-profile/bin/bat
    alias cat=bat
end
