{ config, pkgs, lib, ... }:
let
  cfg = config.sys.hardware;
in
{
  options.sys.hardware = {
    enable = lib.mkEnableOption "hardware defaults" // { default = true; };

    systemdBoot = lib.mkEnableOption "common boot config";
    hardenKernel = lib.mkEnableOption "kernel hardening options" // { default = cfg.isWorkstation; };
    enableKvm = lib.mkEnableOption "kernel hardening options";

    cpuVendor = lib.mkOption {
      type = lib.types.enum [ "intel" "amd" "other" ];

      description = ''
        Vendor for the CPU, meant mostly for x86/x86_64 systems.
      '';
    };

    isWorkstation = lib.mkEnableOption "Workstation-related settings";
  };

  config = lib.mkIf cfg.enable {
    boot = {
      extraModprobeConfig = lib.mkIf cfg.enableKvm ''
        options ${lib.optionalString (cfg.cpuVendor != "other") "kvm_${cfg.cpuVendor}" } nested=1
      '';

      kernel.sysctl = lib.mkIf cfg.hardenKernel {
        # Prevent unintentional fifo writes
        "fs.protected_fifos" = 2;

        # Prevent unintended writes to already-created files
        "fs.protected_regular" = 2;

        # Disable SUID binary dump
        "fs.suid_dumpable" = 0;

        # Require user to have CAP_SYSLOG to use dmesg
        "kernel.dmesg_restrict" = 1;

        # Prevent printing kernel pointers
        "kernel.kptr_restrict" = 2;

        # Disallow profiling at all levels without CAP_SYS_ADMIN
        "kernel.perf_event_paranoid" = 3;

        # Disable "Sysrq" key
        "kernel.sysrq" = 0;

        # Require CAP_BPF to use bpf
        "kernel.unprvileged_bpf_disabled" = 1;

        # Filter ARP packets to be responded on per-interface. Not sure why this isn't the default
        "net.ipv4.conf.all.arp_filter" = 1;

        # Filter Reverse Path
        "net.ipv4.conf.all.rp_filter" = 1;

        # Log impossible addr packets
        "net.ipv4.conf.all.log_martians" = 1;
        "net.ipv4.conf.default.log_martians" = 1;
      };

      kernelParams = (lib.optional cfg.isWorkstation "quiet")
        ++ (lib.optional (cfg.cpuVendor == "intel") "intel_iommu=on");

      loader = lib.mkIf cfg.systemdBoot {
        efi.canTouchEfiVariables = true;

        systemd-boot = {
          enable = true;

          configurationLimit = 10;
          editor = lib.mkDefault false;
        };
      };

      plymouth.enable = cfg.isWorkstation;
    };

    environment.systemPackages = lib.optionals cfg.isWorkstation (with pkgs; [ usbutils pciutils ]);

    hardware = {
      bluetooth = lib.mkIf cfg.isWorkstation {
        enable = true;

        powerOnBoot = false;
        package = pkgs.bluez;
        settings.General.Name = config.networking.hostName;
      };

      cpu.intel.updateMicrocode = cfg.cpuVendor == "intel";
      enableRedistributableFirmware = true;
    };

    services.fwupd.enable = cfg.isWorkstation;
    zramSwap.enable = true;
  };
}
