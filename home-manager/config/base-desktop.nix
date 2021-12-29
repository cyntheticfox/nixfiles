{ config, pkgs, ... }: {
  imports = [
    ./base.nix

    # Modules
    ./gui/kitty.nix
    ./gui/fonts.nix
    ./gui/web.nix
  ];

  home.packages = with pkgs; [
    pcmanfm
    remmina
    xdg_utils
  ];

  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" ];
  };

  services.udiskie.enable = true;

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  xdg.mimeApps.enable = true;

  home.file."wallpaper.png".source = builtins.fetchurl {
    url = "https://github.com/NixOS/nixos-artwork/raw/03c6c20be96c38827037d2238357f2c777ec4aa5/wallpapers/nix-wallpaper-nineish-dark-gray.png";
    sha256 = "9e1214b42cbf1dbf146eec5778bde5dc531abac8d0ae78d3562d41dc690bf41f";
  };
}
