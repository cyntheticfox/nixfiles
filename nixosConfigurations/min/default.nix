{ lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  disko.devices = import ./disk-config.nix { inherit lib; };

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
}
