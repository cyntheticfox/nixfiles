_: {
  fileSystems = {
    "/" = {
      label = "fsroot";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

    "/boot" = {
      label = "boot";
      fsType = "vfat";
    };
  };
}
