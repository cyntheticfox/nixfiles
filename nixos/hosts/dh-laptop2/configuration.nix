# configuration.nix
#
# Edit this configuration file to define what should be installed on
#  your system.  Help is available in the configuration.nix(5) man page
#  and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }: {
  # Import other configuration files
  imports = [
    ./hardware-configuration.nix

    # Users
    ../../config/users/david/configuration.nix

    # Desktop
    ../../config/desktops/sway.nix

    # Services
    ../../config/services/libvirtd.nix
    ../../config/services/cupsd.nix
    ../../config/services/podman.nix
    ../../config/services/clamav.nix
  ];

  sops = {
    gnupg = {
      home = "/var/lib/sops";
      sshKeyPaths = [ ];
    };

    secrets.root-password = {
      sopsFile = ./secrets.yml;
      neededForUsers = true;
    };
  };

  users = {
    mutableUsers = false;
    users.root.passwordFile = config.sops.secrets.root-password.path;
  };

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        editor = false;
      };
    };

    # Use latest release kernel
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "intel_iommu=on"
      "quiet"
      "vga=current"
    ];
    plymouth.enable = true;

    # Add Video4Linux loopback support
    extraModulePackages = with config.boot.kernelPackages; (lib.singleton v4l2loopback);
    extraModprobeConfig = ''
      options v4l2looback video_nr=63
    '';
    kernelModules = [ "v4l2loopback" ];
  };

  zramSwap.enable = true;

  networking = {
    hostName = "dh-laptop2";
    domain = "gh0st.network";

    interfaces = {
      enp1s0.useDHCP = true;
      wlp0s20f3.useDHCP = true;
    };

    # TODO: Add Keyfile configurations
    networkmanager = {
      enable = true;

      packages = with pkgs; (lib.singleton networkmanager-openvpn);
      insertNameservers = [
        "2620:fe::fe"
        "2620:fe::9"
        "9.9.9.9"
        "149.112.112.112"
      ];
      wifi.powersave = true;
    };

    enableIPv6 = true;

    firewall = {
      enable = true;
      allowPing = true;
    };

    wireless.scanOnLowSignal = false;
  };

  time.timeZone = "America/New_York";

  hardware.bluetooth = {
    enable = true;

    powerOnBoot = false;
    package = pkgs.bluezFull;
    settings.General.Name = config.networking.hostName;
  };

  hardware.opengl = {
    enable = true;

    driSupport32Bit = true;

    extraPackages = with pkgs; [
      beignet
      intel-media-driver
      libvdpau-va-gl
      mesa
      vaapiIntel
      vaapiVdpau
    ];

    extraPackages32 = with pkgs.driversi686Linux; [
      beignet
      libvdpau-va-gl
      mesa
      vaapiIntel
      vaapiVdpau
    ];
  };

  # Support Xbox One Controller
  hardware.xpadneo.enable = true;

  # Support Corsiar Keyboard
  hardware.ckb-next.enable = true;

  # Support ZSA Keyboard
  hardware.keyboard.zsa.enable = true;

  environment.systemPackages = with pkgs; [
    # FS tools
    cifs-utils
    lethe
    ntfs3g
    parted
    udiskie

    bluez-tools
    htop
    nixos-icons
    wally-cli
  ];

  programs.gnupg.agent.enable = true;

  # Enable updating firmware
  services.fwupd.enable = true;

  # Enable Steam for gaming
  programs.steam.enable = true;

  # Power config
  services.auto-cpufreq.enable = true;
  services.tlp.enable = true;

  # Sound config
  security.rtkit.enable = true;
  sound.enable = true;
  services.pipewire = {
    enable = true;

    alsa.enable = true;
    jack.enable = true;
    pulse.enable = true;
  };
}
