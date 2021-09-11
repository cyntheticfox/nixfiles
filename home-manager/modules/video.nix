{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    minitube
    tartube
    vlc
    youtube-dl
  ];
}
