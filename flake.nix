{
  description = "Personal dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
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

      nixosModules = {
        dh-laptop2.imports = [
          {
            nixpkgs.overlays = [
              self.overlay
              nixpkgs-wayland.overlay
            ];
          }
          ./home-manager/hosts/dh-laptop2/home.nix
        ];
      };

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

      overlays.ospkgs = final: prev: import ./pkgs {
        pkgs = prev;
        outpkgs = final;
        isOverlay = true;
      };
      overlay = self.overlays.ospkgs;

      legacyPackages = forAllSystems (system: import ./pkgs {
        pkgs = systempkgs { inherit system; };
        isOverlay = false;
      });

      defaultPackage = forAllSystems (system:
        let
          pkgs = systempkgs { inherit system; };
        in
        pkgs.linkFarmFromDrvs "ospkgs" (nixpkgs.lib.filter (drv: !drv.meta.unsupported) (nixpkgs.lib.collect nixpkgs.lib.isDerivation (
          import ./pkgs {
            inherit pkgs;
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
