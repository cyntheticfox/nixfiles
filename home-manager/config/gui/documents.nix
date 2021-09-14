{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    joplin
    libreoffice
    okular
    obsidian
    qpdfview
    xournalpp
    zathura
  ];
}
