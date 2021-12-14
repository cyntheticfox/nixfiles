{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    libreoffice
    zathura
  ];
}
