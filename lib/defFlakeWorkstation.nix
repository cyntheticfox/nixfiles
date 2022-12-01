{ nixpkgs
, home-manager
, nixpkgs-unstable ? null
, nix-index-database ? null
, cpuVendor ? null
, system ? "x86_64-linux"
, modules ? [ ]
}:
assert cpuVendor == null || builtins.isString cpuVendor;
assert builtins.hasAttr "lib" nixpkgs;
assert builtins.hasAttr "nixosSystem" nixpkgs.lib;
assert builtins.hasAttr "nixosModules" home-manager;
assert builtins.hasAttr "home-manager" home-manager.nixosModules;

nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit cpuVendor;

    workstation = true;
  };

  modules = [
    home-manager.nixosModules.home-manager
    ../nixos/config/base.nix
    ../nixos/config/hardware-base.nix

    (_: {
      nix.registry = {
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
          ref = if nixpkgs-unstable != null then nixpkgs-unstable.sourceInfo.rev else nixpkgs.sourceInfo.rev;
        };
      };
    })

    (_: {
      home-manager = {
        backupFileExtension = ".bak";

        sharedModules = [
          ({ pkgs, ... }: {
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
          })
          (
            if
              nix-index-database != null
            then
              ({ pkgs, ... }: {
                home.file.".cache/nix-index/files".source = nix-index-database.legacyPackages."${pkgs.stdenv.hostPlatform.system}".database;
              })
            else
              { }
          )
        ];

        useGlobalPkgs = true;
        useUserPackages = true;
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

                  config.allowUnfree = true;
                }
            else
              super;
        })
      ];
    })
  ] ++ modules;
}
