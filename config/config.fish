#!/usr/local/bin/fish
# Set PROFILE variable for powershell-like referencing of this file
set -U profile (status fish-path)

# Create Alias for ls
alias ls="ls -A -l"

# Edit path
for each in ~/.cargo/bin
    if test -d $each
        and not contains $each $PATH
        set -a PATH $each
    end
end

# Set up starship
if test -x ~/.cargo/bin/starship
    starship init fish | source
end
