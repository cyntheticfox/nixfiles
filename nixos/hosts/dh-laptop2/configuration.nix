# configuration.nix
#
# Edit this configuration file to define what should be installed on
#  your system.  Help is available in the configuration.nix(5) man page
#  and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }: {
  # Import other configuration files
  imports = [
    ./hardware-configuration.nix
    ../../config/users/david.nix
    ../../config/desktops/gnome.nix
    ../../config/services/libvirtd.nix
    ../../config/services/cupsd.nix
    ../../config/services/podman.nix
  ];

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;

      grub = {
        enable = true;
        version = 2;
        efiSupport = true;

        device = "nodev";
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "intel_iommu=on"
      "quiet"
      "vga=current"
    ];
    plymouth.enable = true;
  };

  networking = {
    hostName = "dh-laptop2";
    domain = "gh0st.network";

    interfaces = {
      enp1s0.useDHCP = true;
      wlp0s20f3.useDHCP = true;
    };

    enableIPv6 = true;
    useDHCP = false;

    networkmanager = {
      enable = true;
      wifi = {
        powersave = true;
        scanRandMacAddress = true;
      };
    };

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

  hardware.opengl.extraPackages = with pkgs; [
    vaapiIntel
    intel-media-driver
  ];

  environment.systemPackages = with pkgs; [
    git
    gnupg
    neovim
    neofetch
    htop
    nixos-grub2-theme
    nixos-icons
    openvpn
    openconnect
    pamixer
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

  services.auto-cpufreq.enable = true;
  sound.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    jack.enable = true;
    pulse.enable = false;
  };
}