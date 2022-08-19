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
    nixos.url = "github:NixOS/nixpkgs/nixos-22.05";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs.url = "github:NixOS/nixpkgs/release-22.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nix-index-database.url = "github:houstdav000/nix-index-database-stable";

    impermanence.url = "github:nix-community/impermanence";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixos";
    };

    sops-nix-unstable = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixos-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";
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
            unstableIfElse = unstableFunc: stableFunc:
              if
                unstable
              then
                unstableFunc
              else
                stableFunc;
            username = "david";
            home-manager = with inputs; unstableIfElse home-manager-unstable home-manager;
          in
          home-manager.lib.homeManagerConfiguration {
            inherit system username;

            homeDirectory = "/home/${username}";

            configuration = _: {
              imports = modules;
            };
          };

        defFlakeSystem =
          { unstable ? false
          , workstation ? false
          , cpuVendor ? null
          , system ? "x86_64-linux"
          , modules ? [ ]
          }:
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
            baseModules = (
              if
                unstable
              then
                [
                  ./nixos/config/base-unstable.nix
                  ({ config, pkgs, ... }: {
                    nixpkgs.overlays = [
                      (final: prev: {
                        nixos-stable = import inputs.nixos {
                          inherit system;

                          config.allowUnfree = true;
                        };

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
                  ./nixos/config/base.nix
                  ({ config, pkgs, ... }: {
                    nixpkgs.overlays = [
                      (final: prev: {
                        nixos-unstable = import inputs.nixos-unstable {
                          inherit system;

                          config.allowUnfree = true;
                        };
                      })
                      (final: prev: {
                        nixpkgs-unstable = import inputs.nixpkgs-unstable {
                          inherit system;

                          config.allowUnfree = true;
                        };
                      })
                    ];
                  })
                ]
            ) ++ [
              ({ config, pkgs, ... }: {
                nixpkgs.overlays = [
                  (final: prev: {
                    nixpkgs-master = import inputs.nixpkgs-master {
                      inherit system;

                      config.allowUnfree = true;
                    };
                  })
                ];
              })
              ./nixos/config/hardware-base.nix
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
              inherit self cpuVendor workstation unstable;
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
        min = self.lib.defFlakeSystem {
          modules = [ ./nixos/hosts/min/configuration.nix ];
        };

        dh-laptop2 = self.lib.defFlakeSystem {
          cpuVendor = "intel";
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
          cpuVendor = "intel";
          workstation = true;

          modules = [
            inputs.nixos-hardware.nixosModules.framework
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
              packages = with pkgs; [
                git
                gnupg
                pinentry-qt
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

              shellHook = ''
                ${self.checks."${system}".pre-commit-check.shellHook}

                alias g="git"
                alias ga="git add"
                alias gaa="git add --all"
                alias gc="git commit"
                alias gcmsg="git commit -m"
                alias gd="git diff"
                alias gl="git pull"
                alias gp="git push"
                alias gsb="git status -sb"
                alias n="nix"
                alias nfu="nix flake update"
                alias nosswf="nixos-rebuild switch --use-remote-sudo --flake ."
                alias v="nvim"
              '';
            };
        });
    };
}
