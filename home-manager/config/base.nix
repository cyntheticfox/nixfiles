{ config, pkgs, ... }:

let
  personal_email = "houstdav000@gmail.com";
  personal_github = "houstdav000";
in {
  # Enable home-manager
  programs.home-manager.enable = true;

  imports = [
    ./tui/shell.nix
  ];

  home.packages = with pkgs; [
    aria2
    file
    git
    gnupg
    neofetch
    neovim
    openssh
    p7zip
    pinentry
    rbw
    smbclient
    tmux
    traceroute
    unzip
    whois
    zip

    # NeoVim Tools
    code-minimap
    libtool
    tree-sitter
  ];

  xdg.userDirs = {
    enable = true;
    desktop = "$HOME";
    documents = "$HOME/docs";
    download = "$HOME/tmp";
    music = "$HOME/music";
    pictures = "$HOME/pics";
    publicShare = "$HOME/public";
    templates = "$HOME/.templates";
    videos = "$HOME/videos";
  };

  home.sessionVariables = {
    # Set more user information
    "EMAIL" = personal_email;
    "GITHUB_USER" = personal_github;

    # Set LESS colors
    "LESS_TERMCAP_mb" = "$'\e[01;31m'";
    "LESS_TERMCAP_md" = "$'\e[01;34m'";
    "LESS_TERMCAP_me" = "$'\e[0m'";
    "LESS_TERMCAP_se" = "$'\e[0m'";
    "LESS_TERMCAP_so" = "$'\e[01;31m'";
    "LESS_TERMCAP_ue" = "$'\e[0m'";
    "LESS_TERMCAP_us" = "$'\e[01;32m'";

    # Set runtime dir
    "XDG_RUNTIME_DIR" = "$HOME/tmp";
  };

  home.sessionPath = [
    "$HOME/bin"
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
  ];

  home.file = {
    ".editorconfig".source = ../../home/.editorconfig;

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
