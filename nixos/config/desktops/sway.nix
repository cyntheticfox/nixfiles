# sway-configuration.nix
#
# https://nixos.wiki/wiki/Sway

{ config, pkgs, lib, ... }:
let
  gtk-theme = "Adapta-Nokto";
  icon-theme = "Adwaita";
  cursor-theme = "Adwaita";
  sway-gsettings-desktop-schemas = pkgs.runCommand "sway-gsettings-desktop-schemas" { preferLocalBuild = true; } ''
    mkdir -p $out/share/gsettings-schemas/sway-gsettings-overrides/glib-2.0/schemas/

    cp -rf ${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/*/glib-2.0/schemas/*.xml $out/share/gsettings-schemas/sway-gsettings-overrides/glib-2.0/schemas/

    cat - >$out/share/gsettings-schemas/sway-gsettings-overrides/glib-2.0/schemas/sway-interface.gschema.override <<- EOF
      [org.gnome.desktop.interface]
      gtk-theme='${gtk-theme}'
      icon-theme='${icon-theme}'
      cursor-theme='${cursor-theme}'
    EOF

    ${pkgs.glib.dev}/bin/glib-compile-schemas $out/share/gsettings-schemas/sway-gsettings-overrides/glib-2.0/schemas/
  '';
in
{
  ### Force above GTK Theming
  #
  environment.sessionVariables.NIX_GSETTINGS_OVERRIDES_DIR = "${sway-gsettings-desktop-schemas}/share/gsettings-schemas/sway-gsettings-overrides/glib-2.0/schemas";

  programs = {
    ### Enable Sway window-manager
    #
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [
        # Theming
        adapta-gtk-theme
        gnome_themes_standard
        papirus-icon-theme

        # Util
        grim
        imv
        jq
        kanshi
        mako
        pavucontrol
        playerctl
        polkit_gnome
        qt5.qtwayland
        slurp
        swayidle
        swaylock-effects
        sway-contrib.grimshot
        wf-recorder
        wl-clipboard
        wlogout
        wofi
      ];
    };

    ### Add X11 Compatibility
    #
    xwayland.enable = true;

    ### Enable backlight control
    # Users must be added to the "video" group
    #
    light.enable = true;
  };

  ### Define compatibility variables
  # Some Programs don't use wayland by default and have to be told, so tell
  #  them.
  #
  environment.sessionVariables = {
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM = "wayland-egl";
    WLR_NO_HARDWARE_CURSORS = "1";
    XDG_SESSION_TYPE = "wayland";
  };

  xdg.portal = {
    enable = true;
    gtkUsePortal = true;
    wlr.enable = true;
  };

  services.gnome.gnome-keyring.enable = true;

  gtk.iconCache.enable = true;

  fonts.enableDefaultFonts = true;

  qt5 = {
    enable = true;
    style = "adwaita-dark";
    platformTheme = "gnome";
  };

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];

  ### Add a login manager
  # Provides greetd as a login manager
  #
  services.greetd = {
    enable = true;
    settings = {
      terminal.vt = 7;
      default_session.command = lib.concatStringsSep " " [
        "${pkgs.greetd.tuigreet}/bin/tuigreet"
        "--cmd \"${pkgs.sway}/bin/sway\""
        "--time"
        "--asterisks"
        "--remember"
      ];
    };
  };
}
