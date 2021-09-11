{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    glow
    joplin
    libreoffice
    okular
    obsidian
    qpdfview
    xournalpp
    zathura
  ];
}
