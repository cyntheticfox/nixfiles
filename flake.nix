{
  description = "Personal dotfiles";

  nixConfig = {
    extra-experimental-features = "nix-command flakes";
    extra-substituters =
      "https://cache.nixos.org https://nix-community.cachix.org";
    extra-trusted-public-keys =
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
  };

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

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }@inputs:
    with inputs;

    let
      supportedSystems = with nixpkgs.lib; (intersectLists (platforms.x86_64 ++ platforms.aarch64) platforms.linux);

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      lib = {
        hmConfig =
          { system ? "x86_64-linux", modules ? [ ] }:
          home-manager.lib.homeManagerConfiguration {
            inherit system;
            username = "david";
            homeDirectory = "/home/${username}";

            configuration = _: {
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


      checks = {
        x86_64-linux = nixpkgs.lib.genAttrs (builtins.attrNames self.nixosConfigurations) (name: self.nixosConfigurations."${name}".config.system.build.toplevel);
      } // forAllSystems (system: {
        pre-commit-check = pre-commit-hooks.lib."${system}".run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
            statix.enable = true;
          };
        };
      });

      devShells = forAllSystems (system:
        {
          default =
            let
              pkgs = import nixpkgs {
                inherit system;
                overlays = [ sops-nix.overlay ];
              };
            in
            pkgs.mkShell {
              inherit (self.checks."${system}".pre-commit-check) shellHook;
              nativeBuildInputs = with pkgs; [
                # pre-commit
                pre-commit

                # Nix formatter
                alejandra
                nixfmt
                nixpkgs-fmt

                # Nix linting
                nix-linter
                statix

                # sops-nix
                sops
                sops-init-gpg-key
                sops-import-keys-hook
              ];
              sopsPGPKeyDirs = [
                ./keys/hosts
                ./keys/users
              ];
            };
        });
    };
}
