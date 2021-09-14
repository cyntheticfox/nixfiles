{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    mpd
    ncmpcpp
  ];
}
