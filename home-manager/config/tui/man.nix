{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    manpages
    posix_man_pages
  ];

  programs.man = {
    enable = true;
    generateCaches = true;
  };
}
