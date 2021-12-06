{ config, pkgs, ... }: {

  # Enable home-manager
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    bat
    direnv
    exa
    file
    git
    gnupg
    htop
    neofetch
    neovim
    p7zip
    procs
    starship
    smbclient
    tmux
    unzip
    vim
    w3m
    zip
    zsh

    # NeoVim Tools
    code-minimap
    libtool
    tree-sitter
  ];

  home.file = {
    ".profile".source = ../../home/.profile;
    ".bashrc".source = ../../home/.bashrc;
    ".bash_profile".source = ../../home/.bash_profile;
    ".editorconfig".source = ../../home/.editorconfig;
    ".vimrc".source = ../../home/.vimrc;
    ".zshrc".source = ../../home/.zshrc;

    ".config" = {
      source = ../../home/.config;
      recursive = true;
    };

    ".config/kitty/aura-theme.conf".source = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/daltonmenezes/aura-theme/main/packages/kitty/aura-theme.conf";
      sha256 = "03c8c9e1bf283bf8380379183f39168c45a05c3fd4b22ab54c156675d8e519f1";
    };

    ".ssh" = {
      source = ../../home/.ssh;
      recursive = true;
    };

    ".gnupg" = {
      source = ../../home/.gnupg;
      recursive = true;
    };

    "wallpaper.png".source = builtins.fetchurl {
      url = "https://github.com/NixOS/nixos-artwork/raw/03c6c20be96c38827037d2238357f2c777ec4aa5/wallpapers/nix-wallpaper-nineish-dark-gray.png";
      sha256 = "9e1214b42cbf1dbf146eec5778bde5dc531abac8d0ae78d3562d41dc690bf41f";
    };
  };
}
