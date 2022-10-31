{ pkgs, ... }: {
  home.packages = with pkgs; [
    file
    fd
    nixos-unstable.fq
    p7zip
    ripgrep
    unzip
    whois
    zip
  ];
}
