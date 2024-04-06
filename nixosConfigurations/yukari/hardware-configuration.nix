{ config, pkgs, ... }: {
  boot = {
    initrd = {
      availableKernelModules = [
        "ahci"
        "nvme"
        "sd_mod"
        "sdhci_pci"
        "thunderbolt"
        "usb_storage"
        "usbcore"
        "usbhid"
        "xhci_pci"
      ];

      kernelModules = [
        "dm-snapshot"
        "i915"
        "nls_cp437"
        "nls_iso8859-1"
        "vfat"
      ];

      luks.devices."nixos-enc" = {
        device = "/dev/disk/by-partlabel/root";
        preLVM = true;
      };
    };

    extraModprobeConfig = "options v4l2loopback video_nr=63";
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call v4l2loopback ];
    kernel.sysctl."dev.i915.perf_stream_paranoid" = 0;
    kernelModules = [ "v4l2loopback" ];
    # kernelPackages = pkgs.linuxPackages_latest;
  };

  fileSystems =
    let
      fsroot_subvol = subvol: neededForBoot: {
        inherit neededForBoot;

        label = "fsroot";
        fsType = "btrfs";
        options = [ "subvol=${subvol}" ];
      };
    in
    {
      "/" = {
        device = "none";
        fsType = "tmpfs";
        options = [ "defaults" "size=12G" "mode=755" ];
      };

      "/state" = fsroot_subvol "state" true;

      "/persist" = fsroot_subvol "persist" true;
      "/nix" = fsroot_subvol "nix" false;

      "/boot" = {
        label = "boot";
        fsType = "vfat";
      };
    };

  # Support mouse configuration
  services = {
    ratbagd.enable = true;
    thermald.enable = true;

    tlp = {
      enable = true;

      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "powersave";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

        INTEL_GPU_MIN_FREQ_ON_AC = 100;
        INTEL_GPU_MIN_FREQ_ON_BAT = 100;
        INTEL_GPU_MAX_FREQ_ON_AC = 1000;
        INTEL_GPU_MAX_FREQ_ON_BAT = 1000;
        INTEL_GPU_BOOST_FREQ_ON_AC = 1000;
        INTEL_GPU_BOOST_FREQ_ON_BAT = 1000;

        START_CHARGE_THRESH_BAT0 = 75;
        STOP_CHARGE_THRESH_BAT0 = 80;
        START_CHARGE_THRESH_BAT1 = 75;
        STOP_CHARGE_THRESH_BAT1 = 80;
      };
    };
  };

  hardware = {
    cpu.intel.updateMicrocode = true;
    keyboard.zsa.enable = true;

    opengl = {
      enable = true;

      driSupport32Bit = true;

      extraPackages = with pkgs; [
        beignet
        intel-media-driver
        intel-vaapi-driver
        libvdpau-va-gl
        mesa
        vaapiVdpau
        vdpauinfo
      ];

      extraPackages32 = with pkgs.driversi686Linux; [
        beignet
        intel-vaapi-driver
        libvdpau-va-gl
        mesa
        vaapiVdpau
      ];
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";
  swapDevices = [ ];

  sys.hardware = {
    systemdBoot = true;
    enableKvm = true;
  };
}
