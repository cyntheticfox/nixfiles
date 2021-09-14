{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    # Bash/Shell
    nodePackages.bash-language-server

    # C/C++
    ccls

    # C#
    omnisharp-roslyn

    # Dockerfile
    nodePackages.dockerfile-language-server-nodejs

    # Elixir
    elixir_ls

    # Erlang
    erlang-ls

    # General
    nodePackages.diagnostic-languageserver # For use with any linter!

    # Go
    gopls
    go-langserver

    # Haskell
    haskellPackages.haskell-language-server

    # Javascript
    nodePackages.typescript-language-server

    # Nix
    rnix-lsp

    # Python
    python-language-server

    # Rust
    rust-analyzer

    # Terraform
    terraform-ls

    # YAML
    nodePackages.yaml-language-server
  ];
}
