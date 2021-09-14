{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    termite
    fira-code
    remmina
    shutter
    xsel
  ];
}
