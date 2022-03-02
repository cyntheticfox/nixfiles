{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    file
    fd
    fq
    p7zip
    ripgrep
    unzip
    whois
    zip
  ];
}
