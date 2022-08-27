{ config, pkgs, lib, workstation, cpuVendor, ... }:
let
  intelAmdFunc = i: a:
    if
      cpuVendor == "intel"
    then
      i
    else
      if
        cpuVendor == "amd"
      then
        a
      else
        null;

  intelOnlyFunc = f:
    if
      cpuVendor == "intel"
    then
      f
    else
      null;

  amdOnlyFunc = f:
    if
      cpuVendor == "amd"
    then
      f
    else
      null;

  nologIfWorkstation = if workstation then "quiet" else null;
  iommuKernelParam = intelOnlyFunc "intel_iommu=on";

  kvmModProbeOpt = intelAmdFunc "kvm_intel" "kvm_amd";

in
{
  boot = {
    kernel.sysctl = {
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

      # # Disable late module loading
      # "kernel.modules_disabled" = 1;

      # Disallow profiling at all levels without CAP_SYS_ADMIN
      "kernel.perf_event_paranoid" = 3;

      # Disable "Sysrq" key
      "kernel.sysrq" = 0;

      # Require CAP_BPF to use bpf
      "kernel.unprvileged_bpf_disabled" = 1;

      # Require process to have CAP_SYS_PTRACE and use PTRACE_ATTACH or PTRACE_TRACEME
      #"kernel.yama.ptrace_scope" = 2;

      # Filter ARP packets to be responded on per-interface. Not sure why this isn't the default
      "net.ipv4.conf.all.arp_filter" = 1;

      # Filter Reverse Path
      "net.ipv4.conf.all.rp_filter" = 1;

      # Log impossible addr packets
      "net.ipv4.conf.all.log_martians" = 1;
      "net.ipv4.conf.default.log_martians" = 1;
    };

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        editor = lib.mkDefault false;
      };
    };

    # Enable a fancy loading screen on boot
    plymouth.enable = true;

    kernelParams = [
      nologIfWorkstation
      iommuKernelParam
      #"vga=current"
    ];

    extraModprobeConfig = ''
      options ${kvmModProbeOpt} nested=1
    '';
  };

  zramSwap.enable = true;

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = cpuVendor == "intel";
  services.fwupd.enable = true;

  hardware.bluetooth =
    if
      workstation
    then
      {
        enable = true;

        powerOnBoot = false;
        package = pkgs.bluezFull;
        settings.General.Name = config.networking.hostName;
      }
    else
      { };
}
