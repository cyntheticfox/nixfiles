{ config, pkgs, ... }: {
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

  programs.nix-index.enable = true;

  xdg.userDirs = {
    enable = true;
    desktop = "${config.home.homeDirectory}";
    documents = "${config.home.homeDirectory}/docs";
    download = "${config.home.homeDirectory}/tmp";
    music = "${config.home.homeDirectory}/music";
    pictures = "${config.home.homeDirectory}/pics";
    publicShare = "${config.home.homeDirectory}/public";
    templates = "${config.home.homeDirectory}/.templates";
    videos = "${config.home.homeDirectory}/videos";
  };

  home.sessionPath = [ "${config.home.homeDirectory}/.cargo/bin" ];
}
