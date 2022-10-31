{ modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "ohci_pci"
    "ehci_pci"
    "uhci_hcd"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/fsroot";
      fsType = "btrfs";
      options = [ "subvol=nixos" ];
    };

    "/mnt/share" = {
      device = "/dev/disk/by-label/data";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };
  };

  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];

}
