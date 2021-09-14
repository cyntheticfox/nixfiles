{ config, pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  # Enable home-manager
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    bashInteractive_5
    bat
    direnv
    exa
    file
    git
    gnupg
    htop
    libtool
    neofetch
    neovim
    p7zip
    procs
    starship
    tmux
    tree-sitter
    unzip
    w3m
    zip
    zsh
  ];

  home.file = {
    ".profile".source = ../../home/.profile;
    ".bashrc".source = ../../home/.bashrc;
    ".bash_profile".source = ../../home/.bash_profile;
    ".editorconfig".source = ../../home/.editorconfig;
    ".zshrc".source = ../../home/.zshrc;

    ".config" = {
      source = ../../home/.config;
      recursive = true;
    };

    ".ssh" = {
      source = ../../home/.ssh;
      recursive = true;
    };

    ".gnupg" = {
      source = ../../home/.gnupg;
      recursive = true;
    };
  };
}
