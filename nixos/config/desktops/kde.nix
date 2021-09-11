# kde-configuration.nix
#
# KDE Plasma Desktop Manager Definition and configuration file

{ config, pkgs, lib, ... }: {
  services.xserver = {
    enable = true;
    autorun = true;
    layout = "us";
    desktopManager.plasma5.enable = true;
    displayManager = {
      defaultSession = "plasma5";
      sddm = {
        enable = true;
        autoNumlock = true;
      };
      autoLogin = {
        enable = true;
        user = "david";
      };
      hiddenUsers = [ "nobody" ];
    };
    libinput = {
      enable = true;
      accelProfile = "flat";
      disableWhileTyping = true;
      middleEmulation = false;
      naturalScrolling = false;
      scrollMethod = "twofinger";
      tapping = true;
    };
    terminateOnReset = true;
    useGlamor = true;
    videoDrivers = [ "intel" "vmware" "modesetting" ];
  };

  hardware.opengl.driSupport32Bit = true;

  programs.gnupg.agent.pinentryFlavor = "qt";
}
