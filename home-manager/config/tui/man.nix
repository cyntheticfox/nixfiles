{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    man-pages
    man-pages-posix
    stdmanpages
  ];

  programs.man = {
    enable = true;
    generateCaches = true;
  };
}
