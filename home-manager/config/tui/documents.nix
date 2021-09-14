{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    glow
    pandoc
    texlive.combined.scheme-basic
    xsv
  ];
}
