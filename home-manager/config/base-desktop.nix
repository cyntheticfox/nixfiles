{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    termite
    fira-code
    nerdfonts
    remmina
    shutter
    xsel
  ];
}
