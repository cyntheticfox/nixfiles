{ config, pkgs, ... }: {
  imports = [
    ../../config/sway.nix

    # Desktop modules
    ../../config/gui/chat.nix
    ../../config/gui/dev.nix
    ../../config/gui/documents.nix
    ../../config/gui/games.nix
    ../../config/gui/libvirt.nix
    ../../config/gui/music.nix
    ../../config/gui/teams.nix
    ../../config/gui/video.nix

    # Terminal modules
    ../../config/tui/cloud.nix
    ../../config/tui/dev.nix
    ../../config/tui/documents.nix
    ../../config/tui/music.nix
  ];

  home.stateVersion = "22.05";
}
