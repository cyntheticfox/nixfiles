{ lib, modulesPath, ... }:
let
  enc = import ../../enc/marisa-state.nix;
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  networking.useDHCP = false;
  systemd.network = {
    enable = true;

    networks."40-eth" = {
      inherit (enc) address gateway;
      name = "en*";
      DHCP = "no";
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
