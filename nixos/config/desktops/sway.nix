# sway-configuration.nix
#
# https://nixos.wiki/wiki/Sway

{ config, pkgs, lib, ... }: {

  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
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

  programs.qt5ct.enable = true;

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
