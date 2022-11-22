{ pkgs, ... }: {
  imports = [
    # ../home-manager/config/base.nix
    ../home-manager/config/sway.nix

    # GUI modules
    ../home-manager/config/gui/chat.nix
    ../home-manager/config/gui/dev.nix
    ../home-manager/config/gui/documents.nix
    ../home-manager/config/gui/games.nix
    ../home-manager/config/gui/libvirt.nix
    ../home-manager/config/gui/music.nix
    ../home-manager/config/gui/networking.nix
    ../home-manager/config/gui/teams.nix
    ../home-manager/config/gui/video.nix

    # Terminal modules
    ../home-manager/config/tui/cloud.nix
    ../home-manager/config/tui/dbg.nix
    ../home-manager/config/tui/dev.nix
    ../home-manager/config/tui/documents.nix
    ../home-manager/config/tui/music.nix
    ../home-manager/config/tui/podman.nix
    ../home-manager/config/tui/sec.nix
  ];

  home.packages = with pkgs; [
    mozwire
  ];

  sys = {
    fonts.enable = true;
    keyboard.enable = true;
    shell.enable = true;
  };
}
