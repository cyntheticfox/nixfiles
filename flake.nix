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
    nixos.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/release-21.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixos";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixos";
    };

    sops-nix-unstable = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixos-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-21.11";
      inputs.nixpkgs.follows = "nixos";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixos-unstable";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, ... }@inputs:
    let
      supportedSystems = with inputs.nixpkgs.lib; (intersectLists (platforms.x86_64 ++ platforms.aarch64) platforms.linux);

      forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      lib = {
        hmConfig =
          { unstable ? false, system ? "x86_64-linux", modules ? [ ] }:
          let
            username = "david";
            home-manager =
              if
                unstable
              then
                inputs.home-manager-unstable
              else
                inputs.home-manager;
          in
          home-manager.lib.homeManagerConfiguration {
            inherit system username;

            homeDirectory = "/home/${username}";

            configuration = _: {
              imports = modules;
            };
          };

        defFlakeSystem =
          { unstable ? false, workstation ? false, system ? "x86_64-linux", modules ? [ ] }:
          let
            nixpkgs =
              if
                unstable
              then
                inputs.nixos-unstable
              else
                inputs.nixos;
            home-manager =
              if
                unstable
              then
                inputs.home-manager-unstable
              else
                inputs.home-manager;
            baseModules =
              if
                unstable
              then
                [ ./nixos/config/base-unstable.nix ]
              else
                [
                  ({ config, pkgs, ... }: {
                    nixpkgs.overlays = [
                      (final: prev: {
                        nixos-unstable = import inputs.nixos-unstable {
                          inherit system;

                          config.allowUnfree = true;
                        };
                      })
                    ];
                  })
                  ./nixos/config/base.nix
                ];
            hmModules =
              if
                workstation
              then
                [
                  home-manager.nixosModules.home-manager
                  ./nixos/config/base-hm.nix
                ]
              else
                [ ];
          in
          nixpkgs.lib.nixosSystem {
            inherit system;

            specialArgs = {
              inherit self;
              inherit (self) inputs outputs;
            };

            modules = baseModules
              ++ hmModules
              ++ modules;
          };
      };

      nixosModules = {
        dh-laptop2.imports = [
          ./home-manager/hosts/dh-laptop2/home.nix
        ];

        dh-framework.imports = [
          ./home-manager/hosts/dh-framework/home.nix
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
          workstation = true;

          modules = [
            inputs.nixos-hardware.nixosModules.common-cpu-intel
            inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
            inputs.nixos-hardware.nixosModules.common-pc-laptop
            inputs.sops-nix.nixosModules.sops
            ./nixos/hosts/dh-laptop2/configuration.nix
          ];
        };

        dh-framework = self.lib.defFlakeSystem {
          workstation = true;

          modules = [
            inputs.nixos-wsl.nixosModules.wsl
            inputs.sops-nix.nixosModules.sops
            ./nixos/hosts/dh-framework/configuration.nix
          ];
        };

        ashley = self.lib.defFlakeSystem {
          modules = [ ./nixos/hosts/ashley/configuration.nix ];
        };
      };

      checks = {
        x86_64-linux = inputs.nixpkgs.lib.genAttrs (builtins.attrNames self.nixosConfigurations) (name: self.nixosConfigurations."${name}".config.system.build.toplevel);
      } // forAllSystems (system: {
        pre-commit-check = inputs.pre-commit-hooks.lib."${system}".run {
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
              pkgs = import inputs.nixpkgs-unstable {
                inherit system;
                overlays = [ inputs.sops-nix-unstable.overlay ];
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
          no-env =
            let
              pkgs = import inputs.nixpkgs-unstable {
                inherit system;
                overlays = [ inputs.sops-nix-unstable.overlay ];
              };
            in
            pkgs.mkShell {
              inherit (self.checks."${system}".pre-commit-check) shellHook;

              nativeBuildInputs = with pkgs; [
                git
                gnupg
                neovim

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
