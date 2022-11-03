{ self
, unstable ? false
, workstation ? false
, cpuVendor ? null
, system ? "x86_64-linux"
, modules ? [ ]
}:
assert cpuVendor == null || builtins.isString cpuVendor;
assert builtins.hasAttr "home-manager" self.inputs;
assert builtins.hasAttr "nixos" self.inputs;
assert builtins.hasAttr "nixos-unstable" self.inputs;
assert builtins.hasAttr "nixpkgs" self.inputs;
assert builtins.hasAttr "nixpkgs-master" self.inputs;
assert builtins.hasAttr "nixpkgs-unstable" self.inputs;
let
  inherit (self) inputs;

  nixos =
    if
      unstable
    then
      inputs.nixos-unstable
    else
      inputs.nixos;
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
              nixos-stable = import inputs.nixos {
                inherit system;

                config.allowUnfree = true;
              };
            })
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
              nixos-unstable = import inputs.nixos-unstable {
                inherit system;

                config.allowUnfree = true;
              };
            })
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
    ({ config, ... }: {
      nixpkgs.overlays = [
        (_: _: {
          nixpkgs-master = import inputs.nixpkgs-master {
            inherit system;

            config.allowUnfree = true;
          };
        })
      ];
    })
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
nixos.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit self cpuVendor workstation unstable inputs;
  };

  modules = baseModules
    ++ hmNixosModules
    ++ modules;
}
