{ self
, inputs
, unstable ? false
, workstation ? false
, cpuVendor ? null
, system ? "x86_64-linux"
, modules ? [ ]
}:
assert cpuVendor == null || builtins.isString cpuVendor;
assert builtins.hasAttr "home-manager" inputs;
assert builtins.hasAttr "home-manager-unstable" inputs;
assert builtins.hasAttr "nixos" inputs;
assert builtins.hasAttr "nixos-unstable" inputs;
assert builtins.hasAttr "nixpkgs" inputs;
assert builtins.hasAttr "nixpkgs-master" inputs;
assert builtins.hasAttr "nixpkgs-unstable" inputs;
let
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
  home-manager =
    if
      unstable
    then
      inputs.home-manager-unstable
    else
      inputs.home-manager;
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
  hmModules =
    if
      workstation
    then
      [
        home-manager.nixosModules.home-manager
        ../nixos/config/base-hm.nix
      ]
    else
      [ ];
in
nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit self cpuVendor workstation unstable;
    inherit (self) inputs;
  };

  modules = baseModules
    ++ hmModules
    ++ modules;
}
