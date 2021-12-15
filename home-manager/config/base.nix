{ config, pkgs, ... }:

let
  personal_email = "houstdav000@gmail.com";
  personal_github = "houstdav000";
in {
  # Enable home-manager
  programs.home-manager.enable = true;

  imports = [
    ./tui/bat.nix
    ./tui/file.nix
    ./tui/git.nix
    ./tui/gnupg.nix
    ./tui/htop.nix
    ./tui/man.nix
    ./tui/neofetch.nix
    ./tui/neovim.nix
    ./tui/rbw.nix
    ./tui/shell.nix
    ./tui/ssh.nix
    ./tui/tmux.nix
  ];

  home.packages = with pkgs; [
    smbclient
    mtr
    traceroute
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

    # Set runtime dir
    "XDG_RUNTIME_DIR" = "$HOME/tmp";
  };

  home.sessionPath = [
    "$HOME/bin"
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
  ];

  home.file.".config" = {
    source = ../../home/.config;
    recursive = true;
  };
}
