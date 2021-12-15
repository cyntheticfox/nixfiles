{ config, pkgs, lib, ... }: {
  home.packages = with pkgs; [
    dejavu_fonts
    fira
    fira-code
    fira-code-symbols
    fira-mono
    nerdfonts
    noto-fonts-emoji
    rictydiminished-with-firacode
  ];

  fonts.fontconfig = {
    enable = true;
  };
}
