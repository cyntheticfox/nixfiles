{ config, pkgs, lib, ... }: {
  imports = [
    ./base.nix

    ./fcitx5.nix

    # Modules
    # ./gui/fonts.nix
    ./gui/kitty.nix
    ./gui/remmina.nix
    ./gui/web.nix
  ];

  home.packages = with pkgs; [
    pcmanfm
    xdg_utils
  ];

  # # TODO: Get this to actually work
  # services.gnome-keyring = {
  #   enable = true;
  #   components = [ "secrets" ];
  # };

  services.udiskie.enable = true;

  gtk = {
    enable = true;

    theme = {
      package = pkgs.nordic;
      name = "Nordic";
    };

    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus";
    };
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  home.shellAliases."open" = "xdg-open";

  xdg.mime.enable = true;
  xdg.mimeApps.enable = true;

  # Reload mime type associations on activation
  home.activation.reload-mimetypes = lib.hm.dag.entryAfter [ "writeBoundary" "checkLinkTargets" ] ''
    $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p $VERBOSE_ARG ${config.xdg.dataHome}/mime/packages
    $DRY_RUN_CMD ${pkgs.shared-mime-info}/bin/update-mime-database $VERBOSE_ARG ${config.xdg.dataHome}/mime
  '';

  # # Pull just my preferred wallpaper from nixos-artwork
  # home.file."wallpaper.png".source = pkgs.fetchurl {
  #   url = "https://github.com/NixOS/nixos-artwork/raw/03c6c20be96c38827037d2238357f2c777ec4aa5/wallpapers/nix-wallpaper-nineish-dark-gray.png";
  #   sha256 = "9e1214b42cbf1dbf146eec5778bde5dc531abac8d0ae78d3562d41dc690bf41f";
  # };
}
