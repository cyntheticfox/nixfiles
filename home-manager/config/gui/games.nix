{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    lutris

    # Emulation
    flips
    retroarchFull

    # Steam
    steam
    winetricks
    wine-wayland
    protontricks

    # Other games
    minecraft
  ];
}
