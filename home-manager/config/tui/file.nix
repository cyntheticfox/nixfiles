{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    fd
    ripgrep
  ];
}
