{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    termite
    fira-code
    noto-fonts-emoji
    nerdfonts
    remmina
    shutter
    xsel
  ];
}
