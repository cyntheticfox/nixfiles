{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    kitty
    fira-code
    noto-fonts-emoji
    nerdfonts
    pcmanfm
    remmina
    rictydiminished-with-firacode
    xsel
  ];
}
