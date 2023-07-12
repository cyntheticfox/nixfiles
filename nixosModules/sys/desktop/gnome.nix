{ config, lib, pkgs, ... }:

let
  cfg = config.sys.desktop.gnome;
in
{
  options.sys.desktop.gnome.enable = lib.mkEnableOption "GNOME Desktop";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs.gnome3; [ gnome-tweaks ];
    hardware.opengl.driSupport32Bit = true;
    programs.gnupg.agent.pinentryFlavor = "gnome3";

    services.xserver = {
      enable = true;

      autorun = true;
      layout = "us";
      desktopManager.gnome.enable = true;

      displayManager = {
        defaultSession = "gnome";

        gdm = {
          enable = true;

          autoSuspend = true;
          debug = false;
          wayland = true;
        };

        hiddenUsers = [ "nobody" ];
      };

      libinput = {
        enable = true;

        touchpad = {
          accelProfile = "flat";
          disableWhileTyping = true;
          middleEmulation = false;
          naturalScrolling = true;
          scrollMethod = "twofinger";
          tapping = true;
        };
      };

      terminateOnReset = true;
      useGlamor = true;
      videoDrivers = [ "intel" "vmware" "modesetting" ];
    };
  };
}
