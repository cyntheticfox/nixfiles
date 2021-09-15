{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    # Bash/Shell
    nodePackages.bash-language-server

    # C/C++
    ccls

    # C#
    omnisharp-roslyn

    # CSS
    nodePackages.vscode-langservers-extracted

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

    # Lua
    sumneko-lua-language-server

    # Nix
    rnix-lsp

    # Python
    python39Packages.python-lsp-server
    python39Packages.python-lsp-black

    # Rust
    rust-analyzer

    # SQL
    sqls

    # Terraform
    terraform-ls

    # YAML
    nodePackages.yaml-language-server

    # Vim
    nodePackages.vim-language-server
  ];
}
