{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.sys.libvirtd;
in
{
  options.sys.libvirtd = {
    enable = mkEnableOption "libvirtd config";

    package = mkPackageOption pkgs "libvirt" { };

    qemuPackage = mkPackageOption pkgs "qemu_kvm" { };
    swtpmPackage = mkPackageOption pkgs "swtpm" { };

    cpuBrand = mkOption {
      type = types.enum [
        "intel"
        "amd"
      ];
      default = "intel";
    };
  };

  config = mkIf cfg.enable {
    boot.kernelModules = [ "kvm-${cfg.cpuBrand}" ];

    virtualisation = {
      kvmgt.enable = true;

      libvirtd = {
        inherit (cfg) enable package;

        onBoot = "ignore";
        onShutdown = "suspend";

        qemu = {
          package = cfg.qemuPackage;
          ovmf.enable = true;
          runAsRoot = true;

          # Since Windows 11 requires a tpm:
          swtpm.enable = true;
        };
      };

      spiceUSBRedirection.enable = true;
    };

    environment.systemPackages = [ cfg.swtpmPackage ];

    # Enable more cgroups control for systemd
    environment.etc."pam.d/system-login" = {
      mode = "0644";
      text = "session    optional    pam_cgfs.so -c freezer,memory,name=systemd,unified";
    };
  };
}
