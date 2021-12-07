# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }: {
  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "sdhci_pci"
      ];
      kernelModules = [ "kvm-intel" "dm-snapshot" "i915" ];
    };
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/fsroot";
      fsType = "btrfs";
      options = [ "subvol=nixos" ];
    };
    "/home" = {
      device = "/dev/disk/by-label/fsroot";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
  };

  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";
}
