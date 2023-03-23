{ mainDisk ? "/dev/sda", ... }: {
  disk."${mainDisk}" = {
    device = mainDisk;
    type = "disk";

    # MBR-compatible EFI
    content = {
      type = "table";
      format = "gpt";

      partitions = [
        {
          name = "boot";
          type = "partition";
          start = "0";
          end = "1M";
          flags = [ "bios_grub" ];
        }
        {
          type = "partition";
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
          type = "partition";
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
