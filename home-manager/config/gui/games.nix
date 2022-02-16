{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    lutris

    # Emulation
    flips
    retroarchFull

    # Steam
    steam
    winetricks
    wine
    protontricks

    # Other games
    minecraft
  ];
}
