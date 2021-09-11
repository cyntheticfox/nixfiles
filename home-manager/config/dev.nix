{ config, pkgs, ... }: {
  imports = [
    ../modules/formatters.nix
    ../modules/git.nix
    ../modules/linters.nix
    ../modules/lsp.nix
  ];

  home.packages = with pkgs; [
    ansible
    cargo
    cloc
    gcc_latest
    deno
    diff-so-fancy
    direnv
    fish
    gnupg
    hyperfine
    jq
    libnotify
    neovim
    nodejs_latest
    pandoc
    poetry
    python
    python3
    starship
    texlive.combined.scheme-full
    tree-sitter
    zsh

    # Repository Management
    pre-commit
    git-secrets
  ];
}
