{ pkgs, ... }: {

  environment.systemPackages = with pkgs.gnome3; [
    gnome-tweaks
  ];

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
        disableWhileTyping = true;
        tapping = true;
        naturalScrolling = true;
        middleEmulation = false;
        accelProfile = "flat";
        scrollMethod = "twofinger";
      };
    };
    terminateOnReset = true;
    useGlamor = true;
    videoDrivers = [ "intel" "vmware" "modesetting" ];
  };

  hardware.opengl.driSupport32Bit = true;

  programs.gnupg.agent.pinentryFlavor = "gnome3";
}
