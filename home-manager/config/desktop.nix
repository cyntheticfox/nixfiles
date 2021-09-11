{ config, pkgs, ... }: {

  imports = [
    ../modules/fonts.nix
    ../modules/web.nix
  ];

  # Desktop Packages
  home.packages = with pkgs; [
    # File managers
    pcmanfm

    # Terminals
    alacritty
    termite

    # Remote
    remmina

    # Email
    thunderbird

    # Snipping
    shutter
    xsel

    # Extractor
    xarchive
  ];
}
