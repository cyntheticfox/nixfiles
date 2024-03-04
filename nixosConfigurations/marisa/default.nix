{ lib, modulesPath, ... }:
let
  enc = import ../../enc/marisa-state.nix;
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  networking = {
    firewall.enable = true;
    useDHCP = false;
    usePredictableInterfaceNames = false;
  };

  systemd.network = {
    enable = true;

    networks."40-eth0" = {
      inherit (enc) address gateway;

      name = "eth0";
      dns = [ "[2620:fe::fe]" "[2620:fe::9]" ];
    };
  };

  sys.sshd = {
    enable = true;
    openFirewall = true;
  };

  users.users.root.openssh.authorizedKeys.keys = [ enc.root-key ];

  disko.devices = import ./disk-config.nix {
    inherit lib;
  };

  boot.loader.grub = {
    enable = true;
  };
}
