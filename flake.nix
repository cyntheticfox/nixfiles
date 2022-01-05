{
  description = "Personal dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs = {
      #   poetry2nix = {
      #     url = "github:nix-community/poetry2nix";
      #     inputs = {
      #       nixpkgs.follows = "nix-alien/nixpkgs";
      #       flake-utils.follows = "nix-alien/flake-utils";
      #     };
      #   };
        flake-utils.url = "github:numtide/flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };

    foosteros = {
      url = "github:lilyinstarlight/foosteros";
      inputs = {
        envfs.follows = "";
        flake-compat.follows = "flake-compat";
        home-manager.follows = "home-manager";
        nix-alien.follows = "nix-alien";
        nix-ld.follows = "";
        nixpkgs.follows = "nixpkgs";
        sops-nix.follows = "sops-nix";
      };
    };

    comma = {
      url = "github:nix-community/comma";
      flake = false;
    };

    ### FIXME: Include support flakes due to busted nix locking
    # See https://github.com/NixOS/nix/issues/5728
    #
    flake-utils.url = "github:numtide/flake-utils";

    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    foosteros.inputs.flake-utils.follows = "flake-utils";
    foosteros.inputs.poetry2nix.follows = "poetry2nix";
    nix-alien.inputs.flake-utils.follows = "flake-utils";
    nix-alien.inputs.poetry2nix.follows = "poetry2nix";
  };

  outputs = { self, ... }@inputs:
    with inputs;

    let
      supportedSystems = with nixpkgs.lib; (intersectLists (platforms.x86_64 ++ platforms.aarch64) platforms.linux);

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      systempkgs = { system }: import nixpkgs {
        inherit system;
        overlays = nixpkgs.lib.attrValues self.overlays;
      };
    in
    {
      lib = {
        hmConfig =
          { system ? "x86_64-linux", modules ? [ ] }:
          home-manager.lib.homeManagerConfiguration {
            inherit system;
            username = "david";
            homeDirectory = "/home/${username}";

            configuration = { pkgs, lib, ... }: {
              imports = modules;
            };
          };

        defFlakeSystem =
          { system ? "x86_64-linux", modules ? [ ] }:
          nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              ./nixos/config/base.nix
              # Add home-manager to all configurations
              home-manager.nixosModules.home-manager
              sops-nix.nixosModules.sops
              {
                config._module.args = {
                  inherit self;
                  inherit (self) inputs outputs;
                };
              }
            ] ++ modules;
          };
      };

      nixosModules.dh-laptop2.imports = [
        ./home-manager/hosts/dh-laptop2/home.nix
      ];

      homeConfigurations = {
        wsl = self.lib.hmConfig {
          modules = [ ./home-manager/hosts/wsl/home.nix ];
        };

        pbp = self.lib.hmConfig {
          system = "aarch64-linux";
          modules = [ ./home-manager/hosts/pbp/home.nix ];
        };
      };

      nixosConfigurations = {
        dh-laptop2 = self.lib.defFlakeSystem {
          modules = [
            nixos-hardware.nixosModules.common-cpu-intel
            nixos-hardware.nixosModules.common-pc-laptop-ssd
            nixos-hardware.nixosModules.common-pc-laptop
            ./nixos/hosts/dh-laptop2/configuration.nix
          ];
        };

        ashley = self.lib.defFlakeSystem {
          modules = [ ./nixos/hosts/ashley/configuration.nix ];
        };
      };

      overlays = {
        nix-alien = nix-alien.overlay;
        foosteros = foosteros.overlay;

        ospkgs = final: prev: import ./pkgs {
          inherit inputs;
          pkgs = prev;
          ospkgs = final;
          isOverlay = true;
        };
      };
      overlay = self.overlays.ospkgs;

      legacyPackages = forAllSystems (system:
        import ./pkgs {
          inherit inputs;
          pkgs = systempkgs { inherit system; };
          isOverlay = false;
        }
      );

      defaultPackage = forAllSystems (system:
        let
          pkgs = systempkgs { inherit system; };
        in
        pkgs.linkFarmFromDrvs "ospkgs" (nixpkgs.lib.filter (drv: !drv.meta.unsupported) (nixpkgs.lib.collect nixpkgs.lib.isDerivation (
          import ./pkgs {
            inherit pkgs inputs;
            allowUnfree = false;
            isOverlay = false;
          }
        )
        ))
      );

      checks = forAllSystems (system: import ./tests {
        pkgs = systempkgs { inherit system; };
        inherit self;
        inherit (self) inputs outputs;
        inherit system;
      });

      devShell = forAllSystems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ sops-nix.overlay ];
        };
      in
      pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          sops
          sops-init-gpg-key
          sops-import-keys-hook
        ];
        sopsPGPKeyDirs = [
          ./keys/hosts
          ./keys/users
        ];
      });
    };
}
