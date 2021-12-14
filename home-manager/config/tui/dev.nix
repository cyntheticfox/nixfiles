{ config, pkgs, ... }: {
  imports = [
    ./lsp.nix
    ./linters.nix
    ./formatters.nix
  ];

  home.packages = with pkgs; [
    ansible
    cargo
    cloc
    gcc_latest
    deno
    hexyl
    hyperfine
    openjdk
    jq
    libnotify
    nodejs_latest
    poetry
    python
    python3

    # Repository Management
    pre-commit
    git-secrets
  ];
}
