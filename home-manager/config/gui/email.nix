{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    thunderbird-wayland
  ];
}
