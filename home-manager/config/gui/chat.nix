{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    discord-canary
    element-desktop
  ];
}
