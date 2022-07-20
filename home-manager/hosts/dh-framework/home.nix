{ config
, pkgs
, ...
}: {
  imports = [
    ../../config/base.nix

    # GUI modules
    ../../config/gui/fonts.nix
    ../../config/gui/remmina.nix

    # Terminal modules
    ../../config/tui/cloud.nix
    ../../config/tui/dbg.nix
    ../../config/tui/dev.nix
    ../../config/tui/documents.nix
    ../../config/tui/music.nix
    ../../config/tui/rss.nix
  ];

  home.packages = with pkgs; [
    mozwire
  ];

  home.stateVersion = "22.05";
}
