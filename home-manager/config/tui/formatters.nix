{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    # Bash/shell
    shfmt

    # C/C++
    astyle

    # Go
    gofumpt

    # JavaScript
    nodePackages.prettier

    # Nix
    nixpkgs-fmt

    # Python
    black

    # Rust
    rustfmt
  ];
}
