{ config, pkgs, lib, ... }:

let
  cfg = config.sys.virt;
in
{
  options.sys.virt.libvirt = {
    enable = lib.mkEnableOption "Libvirt tools";

    managerPackage = lib.mkPackageOption pkgs "virt-manager" { };

    viewerPackage = lib.mkPackageOption pkgs "virt-viewer" { };

    extraPackages = lib.mkOption {
      type = with lib.types; listOf package;
      default = with pkgs; [
        libguestfs
        guestfs-tools
      ];
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.libvirt.enable {
      home.packages = [ cfg.libvirt.managerPackage cfg.libvirt.viewerPackage ] ++ cfg.libvirt.extraPackages;
    })
  ];
}
