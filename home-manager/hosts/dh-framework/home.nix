{ config, pkgs, ... }: {
  imports = [
    # ../../config/base.nix
    ../../config/sway.nix

    # GUI modules
    ../../config/gui/chat.nix
    ../../config/gui/dev.nix
    ../../config/gui/documents.nix
    ../../config/gui/games.nix
    ../../config/gui/libvirt.nix
    ../../config/gui/music.nix
    ../../config/gui/networking.nix
    ../../config/gui/teams.nix
    ../../config/gui/video.nix

    # Terminal modules
    ../../config/tui/cloud.nix
    ../../config/tui/dbg.nix
    ../../config/tui/dev.nix
    ../../config/tui/documents.nix
    ../../config/tui/music.nix
    ../../config/tui/podman.nix
    ../../config/tui/sec.nix
  ];

  home.packages = with pkgs; [
    mozwire
  ];

  home.stateVersion = "22.05";
}
