{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    fd
    pistol
    ranger
    ripgrep
    zstd
  ];
}
