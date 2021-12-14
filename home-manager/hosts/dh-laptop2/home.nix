{ config, pkgs, ... }: {
  imports = [
    ../../config/base-desktop.nix

    # Desktop modules
    ../../config/gui/chat.nix
    ../../config/gui/dev.nix
    ../../config/gui/documents.nix
    ../../config/gui/email.nix
    ../../config/gui/fonts.nix
    ../../config/gui/games.nix
    ../../config/gui/libvirt.nix
    ../../config/gui/music.nix
    ../../config/gui/video.nix
    ../../config/gui/web.nix
    ../../config/gui/work.nix

    # Terminal modules
    ../../config/tui/dev.nix
    ../../config/tui/documents.nix
    ../../config/tui/email.nix
    ../../config/tui/file.nix
    ../../config/tui/networking.nix
  ];

  home.stateVersion = "21.11";
}
