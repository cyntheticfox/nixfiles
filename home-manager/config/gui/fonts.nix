{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    dejavu_fonts
    fira
    firacode-nerdfont
    fira-mono
    font-awesome
    noto-fonts-emoji
    rictydiminished-with-firacode
  ];

  fonts.fontconfig.enable = true;
}
