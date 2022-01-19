{ config, pkgs, ... }: {

  boot.kernelModules = [ "kvm-amd" "kvm-intel" ];
  virtualisation = {
    kvmgt.enable = true;
    libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "suspend";
      qemu = {
        package = pkgs.qemu_kvm;
        ovmf.enable = true;
        runAsRoot = true;
      };
    };
  };

  environment.etc."pam.d/system-login" = {
    mode = "0644";
    text = ''
      session    optional    pam_cgfs.so -c freezer,memory,name=systemd,unified
    '';
  };
}
