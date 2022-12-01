# See https://nixos.wiki/wiki/Sway
{ pkgs, lib, ... }:
let
  gtk-theme = "Adwaita-Dark";
  icon-theme = "Adwaita";
  cursor-theme = "Adwaita";
  sway-dconf-settings = pkgs.writeTextFile {
    name = "sway-dconf-settings";
    destination = "/dconf/sway-custom";
    text = ''
      [org/gnome/desktop/interface]
      gtk-theme='${gtk-theme}'
      icon-theme='${icon-theme}'
      cursor-theme='${cursor-theme}'
    '';
  };

  sway-dconf-db = pkgs.runCommand "sway-dconf-db" { preferLocalBuild = true; } ''
    ${pkgs.dconf}/bin/dconf compile $out ${sway-dconf-settings}/dconf
  '';

  sway-dconf-profile = pkgs.writeText "sway-dconf-profile" ''
    user-db:user
    file-db:${sway-dconf-db}
  '';
in
{
  programs.sway = {
    ### Enable Sway window-manager
    #
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      # Theming
      gnome-themes-extra

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
      sway-contrib.inactive-windows-transparency
      wf-recorder
      wl-clipboard
      wlogout
      wofi
    ];
  };

  ### Force GTK settings via dconf
  #
  programs.dconf.profiles.sway = sway-dconf-profile;

  services.xserver.libinput = {
    enable = true;

    mouse.accelProfile = "flat";
  };

  ### Add X11 Compatibility
  #
  programs.xwayland.enable = true;

  ### Enable backlight control
  # Users must be added to the "video" group
  #
  programs.light.enable = true;

  ### Define compatibility variables
  # Some Programs don't use wayland by default and have to be told, so tell
  #  them.
  #
  environment.sessionVariables = {
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM = "wayland-egl";
    WLR_NO_HARDWARE_CURSORS = "1";
    XDG_SESSION_TYPE = "wayland";
    DCONF_PROFILE = "sway";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    # gtkUsePortal = true;
    wlr.enable = true;
  };

  # services.gnome.gnome-keyring.enable = true;

  gtk.iconCache.enable = true;

  fonts.enableDefaultFonts = true;

  qt5 = {
    enable = true;
    style = "adwaita-dark";
    platformTheme = "gnome";
  };

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
