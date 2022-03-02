{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    man-pages
    man-pages-posix
  ];

  programs.man = {
    enable = true;
    generateCaches = true;
  };
}
