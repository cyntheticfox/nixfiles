{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    audacity
    lmms
  ];
}
