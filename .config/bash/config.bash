#!/bin/bash

# Set prompt-specific environment variables
export SH="bash"

# Pull in basics from .inputrc
set bell-style visible
set completion-query-items 120
set colored-completion-prefix on
set colored-stats on
set completion-ignore-case on
set mark-modified-lines on
set mark-symlinked-directories on
set show-mode-in-prompt on
set visible-stats on

# Run starship prompt
if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
else
    PS1="\u on <\H> in \w\n$SH > "
fi
