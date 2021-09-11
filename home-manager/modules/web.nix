{ config, pkgs, dotfiles, ... }: {
  home.packages = with pkgs; [
    firefox
    chromium
  ];
}
