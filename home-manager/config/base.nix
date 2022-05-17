{ config, pkgs, lib, ... }: {
  # Enable home-manager
  programs.home-manager.enable = true;

  imports = [
    ./tui/bat.nix
    ./tui/file.nix
    ./tui/fuse.nix
    ./tui/git.nix
    ./tui/gnupg.nix
    ./tui/htop.nix
    ./tui/man.nix
    ./tui/neofetch.nix
    ./tui/neovim.nix
    ./tui/passwords.nix
    ./tui/shell.nix
    ./tui/ssh.nix
    ./tui/tmux.nix
    ./tui/todo.nix
  ];

  home.packages = with pkgs; [
    nixos-unstable.comma
    curlie
    dogdns
    gping
    traceroute
  ];

  programs.nix-index.enable = true;

  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";

    userDirs = {
      enable = true;

      createDirectories = true;

      desktop = "${config.home.homeDirectory}";
      documents = "${config.home.homeDirectory}/docs";
      download = "${config.home.homeDirectory}/tmp";
      music = "${config.home.homeDirectory}/music";
      pictures = "${config.home.homeDirectory}/pics";
      publicShare = "${config.home.homeDirectory}/public";
      templates = "${config.home.homeDirectory}/.templates";
      videos = "${config.home.homeDirectory}/videos";

      extraConfig.XDG_SECRETS_DIR = "${config.home.homeDirectory}/.secrets";
    };
  };

  home.sessionPath = [ "${config.home.homeDirectory}/.cargo/bin" ];
}
