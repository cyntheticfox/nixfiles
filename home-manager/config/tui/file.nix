{ pkgs, ... }: {
  home.shellAliases = {
    "glow" = "glow -p";
  };

  home.packages = with pkgs; [
    file
    fd
    glow
    nixpkgs-unstable.fq
    p7zip
    ripgrep
    unzip
    whois
    zip
  ];
}
