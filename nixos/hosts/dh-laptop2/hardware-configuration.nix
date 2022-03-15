{ config, pkgs, ... }: {
  boot = {
    initrd = {
      availableKernelModules = [
        "ahci"
        "nvme"
        "usb_storage"
        "usbcore"
        "sd_mod"
        "sdhci_pci"
        "xhci_pci"
      ];

      kernelModules = [
        "dm-snapshot"
        "i915"
        "kvm-intel"
        "nls_cp437"
        "nls_iso8859-1"
        "usbhid"
        "vfat"
      ];

      luks = {
        # Support for Yubikey PBA
        yubikeySupport = true;

        devices."nixos-enc" = {
          device = "/dev/disk/by-partlabel/root";

          yubikey = {
            slot = 2;
            twoFactor = true;
            gracePeriod = 30; # time in seconds to insert the YubiKey
            keyLength = 64;
            saltLength = 16;

            storage = {
              inherit (config.fileSystems."/boot") device fsType;
              path = "/crypt-storage/default";
            };
          };
        };
      };
    };

    kernel.sysctl."net.ipv4.conf.all.arp_filter" = 1;

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
    extraModprobeConfig =
      let
        modopts = list: builtins.concatStringsSep " " ([ "options" ] ++ list);
      in
      modopts [
        "v4l2looback"
        "video_nr=63"
        "kvm_intel"
        "nested=1"
      ];
    kernelModules = [ "v4l2loopback" ];
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call v4l2loopback ];
  };

  fileSystems =
    let
      fsroot_subvol = subvol: {
        device = "/dev/disk/by-label/fsroot";
        fsType = "btrfs";
        options = [ "subvol=${subvol}" ];
      };
    in
    {
      "/" = fsroot_subvol "root";
      "/home" = fsroot_subvol "home";
      "/nix" = fsroot_subvol "nix";

      "/boot" = {
        device = "/dev/disk/by-label/boot";
        fsType = "vfat";
      };
    };

  zramSwap.enable = true;

  swapDevices = [{
    device = "/dev/disk/by-label/swap";
    priority = 2048;
  }];

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel = {
    updateMicrocode = true;
    sgx.provision.enable = true;
  };

  # Support Xbox One Controller
  hardware.xpadneo.enable = true;

  # Support Corsiar Keyboard
  hardware.ckb-next.enable = true;

  # Support ZSA Keyboard
  hardware.keyboard.zsa.enable = true;

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

  # Power config
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
    };
  };

  # Enable updating firmware
  services.fwupd.enable = true;
}
