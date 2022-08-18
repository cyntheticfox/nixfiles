{ config, lib, workstation, cpuVendor, ... }:
let
  amdIntelFunc = i: a:
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
  iommuKernelParam = intelOnlyFunc "intel_iommu";

  kvmModProbeOpt = amdIntelFunc "kvm_intel" "";

  modopts = list: builtins.concatStringsSep " " ([ "options" kvmModProbeOpt ] ++ list);
in
{
  boot = {
    # Filter ARP packets to be responded on per-interface. Not sure why this isn't the default
    kernel.sysctl."net.ipv4.conf.all.arp_filter" = 1;

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
      "vga=current"
    ];

    extraModprobeConfig = modopts [ "nested=1" ];
  };

  zramSwap.enable = true;

  hardware.enableRedistributableFirmware = true;
  services.fwupd.enable = true;
}
