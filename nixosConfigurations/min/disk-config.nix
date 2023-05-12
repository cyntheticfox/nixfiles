{ mainDisk ? "/dev/sda", ... }: {
  disk.${mainDisk} = {
    device = mainDisk;
    type = "disk";

    # MBR-compatible GPT
    content = {
      type = "table";
      format = "gpt";

      partitions = [
        {
          name = "boot";
          start = "0";
          end = "1M";
          flags = [ "bios_grub" ];
        }
        {
          name = "esp";
          start = "1MiB";
          end = "100MiB";
          bootable = true;

          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        }
        {
          name = "root";
          start = "100MiB";
          end = "100%";
          bootable = true;

          content = {
            type = "filesystem";
            format = "btrfs";
            mountpoint = "/";
          };
        }
      ];
    };
  };
}
