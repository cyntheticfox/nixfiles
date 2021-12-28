{ config, pkgs, ... }: {
  home.packages = with pkgs; [
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
