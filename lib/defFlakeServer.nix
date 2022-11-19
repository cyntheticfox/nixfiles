{ nixpkgs
, cpuVendor ? null
, system ? "x86_64-linux"
, modules ? [ ]
}:
assert cpuVendor == null || builtins.isString cpuVendor;
assert builtins.hasAttr "lib" nixpkgs;
assert builtins.hasAttr "nixosSystem" nixpkgs.lib;
nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit cpuVendor;

    workstation = false;
  };

  modules = [
    ../nixos/config/base.nix
    ../nixos/config/hardware-base.nix
  ] ++ modules;
}
