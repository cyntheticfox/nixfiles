{ pkgs, ... }: {
  home.packages = with pkgs; [
    glow
    pandoc
    xsv
  ];

  programs.texlive = {
    enable = true;

    extraPackages = p: { inherit (p) collection-fontsrecommended; };
  };
}
