{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    flips
    minecraft
    protontricks
    retroarchFull
    steam
    winetricks
    wine
  ];
}
