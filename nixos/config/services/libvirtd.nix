# libvirt-configuration.nix
#
# Uhhhh, TODO: ?

{ config, pkgs, lib, ... }: {

  # environment.systemPackages = with pkgs; [
  #   qemu
  #   qemu-utils
  #   qemu_kvm
  # ];

  boot.kernelModules = [ "kvm-amd" "kvm-intel" ];
  virtualisation = {
    libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "suspend";
      qemu.ovmf.enable = true;
      qemu.runAsRoot = true;
    };
  };
  environment.etc."pam.d/system-login" = {
    mode = "0644";
    text = ''
      session    optional    pam_cgfs.so -c freezer,memory,name=systemd,unified
    '';
  };
}
