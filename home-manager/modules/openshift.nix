{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    minishift
  ];
}
