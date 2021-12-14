{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    # Bash/Shell
    nodePackages.bash-language-server

    # C/C++
    ccls

    # CSS
    nodePackages.vscode-langservers-extracted

    # Dockerfile
    nodePackages.dockerfile-language-server-nodejs

    # Elixir
    elixir_ls

    # Erlang
    erlang-ls

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

    # Terraform
    terraform-ls

    # Vim
    nodePackages.vim-language-server

    # Vue
    nodePackages.vue-language-server

    # YAML
    nodePackages.yaml-language-server
  ];
}
