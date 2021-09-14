{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    minitube
    openshot-qt
    obs-studio
    tartube
    vlc
    youtube-dl
  ];
}
