{ mainDisk ? "/dev/sda", ... }: {
  disk.sda = {
    device = mainDisk;
    type = "disk";

    # MBR-compatible GPT
    content = {
      type = "gpt";

      partitions = {
        boot = {
          name = "boot";
          size = "1M";
          type = "EF02";
        };

        esp = {
          name = "ESP";
          size = "512M";
          type = "EF00";

          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };

        root = {
          size = "100%";

          content = {
            type = "lvm_pv";
            vg = "pool";
          };
        };
      };
    };
  };

  lvm_vg.pool = {
    type = "lvm_vg";
    lvs.root = {
      size = "100%FREE";

      content = {
        type = "filesystem";
        format = "ext4";
        mountpoint = "/";
        mountOptions = [ "defaults" ];
      };
    };
  };
}
