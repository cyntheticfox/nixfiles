{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    nixpkgs-unstable.discord
    nixpkgs-unstable.element-desktop-wayland
  ];
}
