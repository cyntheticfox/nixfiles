{ config, pkgs, lib, ... }: {
  imports = [
    ./base.nix

    # Modules
    ./gui/fonts.nix
    ./gui/email.nix
    ./gui/kitty.nix
    ./gui/remmina.nix
    ./gui/web.nix
  ];

  home.packages = with pkgs; [
    pcmanfm
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

  xdg.mime.enable = true;
  xdg.mimeApps.enable = true;

  # Reload mime type associations on activation
  home.activation.reload-mimetypes = lib.hm.dag.entryAfter [ "writeBoundary" "checkLinkTargets" ] ''
    $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p $VERBOSE_ARG ${config.xdg.dataHome}/mime/packages
    $DRY_RUN_CMD ${pkgs.shared-mime-info}/bin/update-mime-database $VERBOSE_ARG ${config.xdg.dataHome}/mime
  '';

  home.file."wallpaper.png".source = pkgs.fetchurl {
    url = "https://github.com/NixOS/nixos-artwork/raw/03c6c20be96c38827037d2238357f2c777ec4aa5/wallpapers/nix-wallpaper-nineish-dark-gray.png";
    sha256 = "9e1214b42cbf1dbf146eec5778bde5dc531abac8d0ae78d3562d41dc690bf41f";
  };
}
