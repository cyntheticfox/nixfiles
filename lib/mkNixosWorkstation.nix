{ nixpkgs
, flake-registry
, home-manager
, hostname
, domain
, path ? ../nixosConfigurations/${hostname}
, nixpkgs-unstable ? null
, nix-index-database ? null
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
assert builtins.hasAttr "nixosModules" home-manager;
assert builtins.hasAttr "home-manager" home-manager.nixosModules;

let
  nz = a: b: if a != null then a else b;
in
nixpkgs.lib.nixosSystem {
  inherit system specialArgs;

  modules = [
    home-manager.nixosModules.home-manager
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
        (_: super:
          let
            unstablePkgs =
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
          in
          {
            inherit (unstablePkgs) vimPlugins;

            nixpkgs-unstable = unstablePkgs;
          })
      ] ++ overlays;

      home-manager = {
        backupFileExtension = "bak";
        extraSpecialArgs = specialArgs;

        sharedModules = [
          ({ pkgs, lib, ... }: {
            programs.nix-index.enable = true;

            systemd.user = {
              services.nix-index = {
                Unit.Description = "Update nix-index cache";

                Service = {
                  Type = "oneshot";
                  ExecStart = "${pkgs.nix-index}/bin/nix-index";
                };
              };

              timers.nix-index = {
                Install.WantedBy = [ "timers.target" ];

                Unit.Description = "Update nix-index cache";

                Timer = {
                  OnCalendar = "weekly";
                  Persistent = true;
                };
              };
            };

            home.file.".cache/nix-index/files".source = lib.mkIf (nix-index-database != null) nix-index-database.legacyPackages.${system}.database;
          })
        ];

        useGlobalPkgs = true;
        useUserPackages = true;
      };

      sys.hardware = {
        inherit cpuVendor;

        isWorkstation = true;
      };

      system.stateVersion = "23.05";

      networking = {
        inherit domain;

        hostName = hostname;
      };
    })
  ] ++ modules ++ builtins.attrValues nixosModules;
}
