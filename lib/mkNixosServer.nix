{ nixpkgs
, flake-registry
, hostname
, domain
, stateVersion
, path ? ../nixosConfigurations/${hostname}
, nixpkgs-unstable ? null
, cpuVendor ? "other"
, system ? "x86_64-linux"
, nixosModules ? import ../nixosModules
, modules ? [ ]
, overlays ? [ ]
, specialArgs ? { }
}:

assert cpuVendor == null || builtins.isString cpuVendor;
assert builtins.hasAttr "lib" nixpkgs;
assert builtins.hasAttr "nixosSystem" nixpkgs.lib;

let
  nz = v: x: if v != null then v else x;
in
nixpkgs.lib.nixosSystem {
  inherit system specialArgs;

  modules = [
    path

    ({ config, ... }: {
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

      sys.hardware.cpuVendor = cpuVendor;
      system.stateVersion = stateVersion;

      networking = {
        inherit domain;

        hostName = hostname;
      };
    })
  ] ++ modules ++ builtins.attrValues nixosModules;
}
