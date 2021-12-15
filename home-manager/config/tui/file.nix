{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    file
    fd
    p7zip
    ripgrep
    unzip
    whois
    zip
  ];
}
