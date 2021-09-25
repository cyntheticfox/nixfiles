# sway-configuration.nix
#
# https://nixos.wiki/wiki/Sway

{ config, pkgs, lib, ... }:
let
  sway-gsettings-desktop-schemas = pkgs.runCommand "sway-gsettings-desktop-schemas" { preferLocalBuild = true; } ''
    mkdir -p $out/share/gsettings-schemas/sway-gsettings-overrides/glib-2.0/schemas/

    cp -rf ${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/*/glib-2.0/schemas/*.xml $out/share/gsettings-schemas/sway-gsettings-overrides/glib-2.0/schemas/

    cat - >$out/share/gsettings-schemas/sway-gsettings-overrides/glib-2.0/schemas/sway-interface.gschema.override <<- EOF
      [org.gnome.desktop.interface]
      gtk-theme='Adwaita-Dark'
      icon-theme='Adwaita'
      cursor-theme='Adwaita'
    EOF

    ${pkgs.glib.dev}/bin/glib-compile-schemas $out/share/gsettings-schemas/sway-gsettings-overrides/glib-2.0/schemas/
  '';
in
{

  environment.sessionVariables.NIX_GSETTINGS_OVERRIDES_DIR = "${sway-gsettings-desktop-schemas}/share/gsettings-schemas/sway-gsettings-overrides/glib-2.0/schemas";

  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      gnome_themes_standard
      mako
      pavucontrol
      polkit_gnome
      swayidle
      swaylock
      xwayland
      waybar
      wl-clipboard
      wlogout
      wofi
    ];
    extraSessionCommands = ''
      export WLR_NO_HARDWARE_CURSORS=1
    '';
  };

  programs.light.enable = true;

  environment.pathsToLink = [ "/libexec" ];

  environment.systemPackages = with pkgs; [
    gtk-engine-murrine
    gtk_engines
    gsettings-desktop-schemas
    lxappearance
  ];

  qt5 = {
    enable = true;
    style = "adwaita-dark";
    platformTheme = "gnome";
  };

  programs.waybar.enable = true;

  services.xserver = {
    enable = true;
    autorun = true;
    layout = "us";
    displayManager = {
      defaultSession = "sway";
      gdm = {
        enable = true;
        autoSuspend = true;
        debug = false;
        wayland = true;
      };
      hiddenUsers = [ "nobody" ];
    };
    terminateOnReset = true;
    useGlamor = true;
    videoDrivers = [
      "intel"
      "vmware"
      "modesetting"
    ];
  };
}
