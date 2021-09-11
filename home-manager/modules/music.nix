{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    elisa
    rhythmbox
    soundkonverter
  ];
}
