{ self
, unstable ? false
, workstation ? false
, cpuVendor ? null
, system ? "x86_64-linux"
, modules ? [ ]
}:
assert cpuVendor == null || builtins.isString cpuVendor;
assert builtins.hasAttr "home-manager" self.inputs;
assert builtins.hasAttr "nixpkgs" self.inputs;
assert builtins.hasAttr "nixpkgs-unstable" self.inputs;
let
  inherit (self) inputs;

  nixpkgs =
    if
      unstable
    then
      inputs.nixpkgs-unstable
    else
      inputs.nixpkgs;
  baseModules = (
    if
      unstable
    then
      [
        ../nixos/config/base-unstable.nix
        ({ config, ... }: {
          nixpkgs.overlays = [
            (_: _: {
              nixpkgs-stable = import inputs.nixpkgs {
                inherit system;

                config.allowUnfree = true;
              };
            })
          ];
        })
      ]
    else
      [
        ../nixos/config/base.nix
        ({ config, ... }: {
          nixpkgs.overlays = [
            (_: _: {
              nixpkgs-unstable = import inputs.nixpkgs-unstable {
                inherit system;

                config.allowUnfree = true;
              };
            })
          ];
        })
      ]
  ) ++ [
    ../nixos/config/hardware-base.nix
  ];
  hmNixosModules =
    if
      workstation
    then
      [
        inputs.home-manager.nixosModules.home-manager
        ../nixos/config/base-hm.nix
      ]
    else
      [ ];
in
nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit self cpuVendor workstation unstable inputs;
  };

  modules = baseModules
    ++ hmNixosModules
    ++ modules;
}
