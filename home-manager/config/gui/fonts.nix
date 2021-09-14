{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    cascadia-code
    dejavu_fonts
    fira
    fira-code-symbols
    fira-mono
    hack-font
    hasklig
    nerdfonts
    vistafonts
  ];
}
