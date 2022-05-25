{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    nixpkgs-master.discord
    nixpkgs-unstable.element-desktop-wayland
  ];
}
