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
    useDHCP = false;
    usePredictableInterfaceNames = false;
  };

  systemd.network = {
    enable = true;

    networks."eth0" = {
      inherit (enc) Address Gateway;
    };
  };

  boot.loader.grub.enable = true;
  sys.sshd.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [ enc.root-key ];

  disko.devices = import ./disk-config.nix {
    inherit lib;
  };
}
