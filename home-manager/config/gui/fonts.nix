{ pkgs, ... }: {
  home.packages = with pkgs; [
    dejavu_fonts
    fira
    fira-mono
    font-awesome
    noto-fonts-emoji
    rictydiminished-with-firacode

    # Add specific nerdfonts
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  fonts.fontconfig.enable = true;
}
