{ config, pkgs, ... }: {
  imports = [
    ../modules/git.nix
  ];

  home.stateVersion = "20.09";

  nixpkgs.config.allowUnfree = true;

  # Enable home-manager
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    bashInteractive_5
    direnv
    exa
    gnupg
    htop
    libtool
    neofetch
    neovim
    pandoc
    p7zip
    starship
    tmux
    tree-sitter
    w3m
    zsh
  ];
}
