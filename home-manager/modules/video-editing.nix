{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    openshot-qt
    obs-studio
  ];
}
