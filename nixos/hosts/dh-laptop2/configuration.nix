# configuration.nix
#
# Edit this configuration file to define what should be installed on
#  your system.  Help is available in the configuration.nix(5) man page
#  and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }: {
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

    secrets = {
      wireless = {
        sopsFile = ./secrets.yml;
        restartUnits = [ "supplicant-wlp0s20f3.service" ];
      };

      root-password = {
        sopsFile = ./secrets.yml;
        neededForUsers = true;
      };
    };
  };

  users = {
    mutableUsers = false;
    users.root.passwordFile = config.sops.secrets.root-password.path;
  };

  boot = {
    # Use grub for theming and recoverability
    loader = {
      efi.canTouchEfiVariables = true;

      grub = {
        enable = true;
        version = 2;
        efiSupport = true;

        device = "nodev";
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
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    extraModprobeConfig = ''
      options v4l2looback video_nr=63
    '';
    kernelModules = [ "v4l2loopback" ];
  };

  networking = {
    hostName = "dh-laptop2";
    domain = "gh0st.network";

    interfaces = {
      enp1s0.useDHCP = true;
      wlp0s20f3.useDHCP = true;
    };

    supplicant.wlp0s20f3 = {
      driver = "nl80211";
      extraConf = ''
        p2p_disabled=1
      '';
      configFile.path = config.sops.secrets.wireless.path;
      userControlled.enable = true;
    };

    networkmanager = {
      enable = true;
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
    settings.General.Name = "${config.networking.hostName}";
  };


  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;

    extraPackages = with pkgs; [
      beignet
      intel-media-driver
      intel-ocl
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

  security.tpm2.enable = true;

  # Support Xbox One Controller
  hardware.xpadneo.enable = true;

  # Support Corsiar Keyboard
  hardware.ckb-next.enable = true;

  # Support ZSA Keyboard
  hardware.keyboard.zsa.enable = true;

  environment.systemPackages = with pkgs; [
    cifs-utils
    htop
    nixos-grub2-theme
    nixos-icons
    wally-cli
  ];

  programs = {
    vim.defaultEditor = true;
    tmux.enable = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

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
