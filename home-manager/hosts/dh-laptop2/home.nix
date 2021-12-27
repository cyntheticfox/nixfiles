{ config, pkgs, ... }: {
  imports = [
    ../../config/sway.nix

    # Desktop modules
    ../../config/gui/chat.nix
    ../../config/gui/dev.nix
    ../../config/gui/documents.nix
    ../../config/gui/email.nix
    ../../config/gui/games.nix
    ../../config/gui/libvirt.nix
    ../../config/gui/music.nix
    ../../config/gui/video.nix
    ../../config/gui/web.nix
    ../../config/gui/work.nix

    # Terminal modules
    ../../config/tui/dev.nix
    ../../config/tui/cloud.nix
    ../../config/tui/documents.nix
  ];

  home.stateVersion = "22.05";
}
