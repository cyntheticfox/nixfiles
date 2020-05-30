#!/usr/local/bin/fish
# Set PROFILE variable for powershell-like referencing of this file
set -U profile ~/.config/fish/config.fish

# Create Alias for dir
alias dir="la"

# Install fisher if available
if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
end

# Edit path
for each in ~/.cargo/bin ~/.nix-profile/bin
    if test -d $each
        and not contains $each $PATH
        set -a PATH $each
    end
end

# Set up starship
if test -x ~/.cargo/bin/starship
    starship init fish | source
end
