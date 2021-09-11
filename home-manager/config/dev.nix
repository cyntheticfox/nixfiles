{ config, pkgs, ... }: {
  imports = [
    ../modules/formatters.nix
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
    hyperfine
    jq
    libnotify
    nodejs_latest
    poetry
    python
    python3
    texlive.combined.scheme-basic

    # Repository Management
    pre-commit
    git-secrets
  ];
}
