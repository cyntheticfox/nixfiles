{ config, pkgs, ... }: {
  imports = [
    ./base.nix

    # Modules
    ./gui/kitty.nix
  ];

  home.packages = with pkgs; [
    fira-code
    noto-fonts-emoji
    nerdfonts
    pcmanfm
    remmina
    rictydiminished-with-firacode
  ];
}
