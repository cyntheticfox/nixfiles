{ mainDisk ? "/dev/sda", ... }: {
  disk.sda = {
    device = mainDisk;
    type = "disk";

    # MBR-compatible GPT
    content = {
      type = "gpt";

      partitions = {
        boot = {
          size = "1M";
          type = "EF02";
        };

        esp = {
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
            type = "filesystem";
            format = "btrfs";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
