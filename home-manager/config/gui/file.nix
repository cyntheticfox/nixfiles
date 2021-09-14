{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    pcmanfm
    xarchive
  ];
}
