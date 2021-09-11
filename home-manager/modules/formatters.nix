{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    # Bash/shell
    bashate
    shfmt

    # C/C++
    astyle

    # Go
    gofumpt

    # Javascript
    nodePackages.prettier

    # Nix
    nixpkgs-fmt
    nixfmt

    # Python
    pythonPackages.autopep8
    black

    # Rust
    rustfmt
  ];
}
