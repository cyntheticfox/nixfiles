{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    virt-manager
    virt-viewer
  ];
}