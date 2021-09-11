{ config, pkgs, ... }: {
  imports = [
    ../modules/networking.nix
  ];
  home.packages = with pkgs; [
    bat
    fd
    file
    pistol
    procs
    ranger
    ripgrep
    unzip
    wireguard
    xsv
    zip
    zstd
  ];
}
