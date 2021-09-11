{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    minecraft
    protontricks
    steam
    winetricks
    wine
  ];
}
