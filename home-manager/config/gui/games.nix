{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    lutris

    # Emulation
    flips
    retroarch

    # itch.io
    #nixpkgs-master.itch

    # Steam
    steam
    winetricks
    nixos-unstable.wine-wayland
    protontricks

    # Other games
    minecraft
  ];
}
