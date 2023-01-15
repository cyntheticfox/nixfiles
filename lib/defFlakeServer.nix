{ nixpkgs
, flake-registry
, nixpkgs-unstable ? null
, cpuVendor ? null
, system ? "x86_64-linux"
, nixosModules ? { }
, modules ? [ ]
, overlays ? [ ]
}:

assert cpuVendor == null || builtins.isString cpuVendor;
assert builtins.hasAttr "lib" nixpkgs;
assert builtins.hasAttr "nixosSystem" nixpkgs.lib;

let
  nz = v: x: if v != null then v else x;
in
nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit cpuVendor;

    workstation = false;
  };

  modules = [
    ../nixos/config/hardware-base.nix

    (_: {
      nix = {
        settings.flake-registry = "${flake-registry}/flake-registry.json";

        registry = {
          nixpkgs.to = {
            type = "github";
            owner = "NixOS";
            repo = "nixpkgs";
            ref = nixpkgs.sourceInfo.rev;
          };

          nixpkgs-unstable.to = {
            type = "github";
            owner = "NixOS";
            repo = "nixpkgs";
            ref = (nz nixpkgs-unstable nixpkgs).sourceInfo.rev;
          };
        };
      };
    })

    ({ config, ... }: {
      nixpkgs.overlays = [
        (_: super: {
          nixpkgs-unstable =
            if
              nixpkgs-unstable != null
            then
              import nixpkgs-unstable
                {
                  inherit system;

                  config.allowUnfree = config.nixpkgs.config.allowUnfree;
                }
            else
              super;
        })
      ] ++ overlays;
    })

    (_: {
      system.stateVersion = "22.11";
    })
  ] ++ modules ++ builtins.attrValues nixosModules;
}
