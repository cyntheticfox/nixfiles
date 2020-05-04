# Create Alias for ls
alias ls="ls -Al"

# Set up starship
set PATH ~/.cargo/bin $PATH

starship init fish | source
