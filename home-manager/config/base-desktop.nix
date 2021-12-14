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

  home.file."wallpaper.png".source = builtins.fetchurl {
    url = "https://github.com/NixOS/nixos-artwork/raw/03c6c20be96c38827037d2238357f2c777ec4aa5/wallpapers/nix-wallpaper-nineish-dark-gray.png";
    sha256 = "9e1214b42cbf1dbf146eec5778bde5dc531abac8d0ae78d3562d41dc690bf41f";
  };
}
