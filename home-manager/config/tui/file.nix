{ pkgs, ... }: {
  home.shellAliases = {
    "glow" = "glow -p";
  };

  home.packages = with pkgs; [
    file
    fd
    glow
    nixos-unstable.fq
    p7zip
    ripgrep
    unzip
    whois
    zip
  ];
}
