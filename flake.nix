{
  description = "Personal dotfiles";

  nixConfig = {
    extra-experimental-features = "ca-derivations";
    extra-substituters =
      "https://cache.nixos.org https://nix-community.cachix.org";
    extra-trusted-public-keys =
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    pure-eval = true;
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";

    nix-index-database.url = "github:houstdav000/nix-index-database-stable";

    impermanence.url = "github:nix-community/impermanence";

    gitignore = {
      url = "github:hercules-ci/gitignore.nix";

      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    flake-registry = {
      url = "github:/NixOS/flake-registry";
      flake = false;
    };

    nmt = {
      url = "gitlab:rycee/nmt?rev=d83601002c99b78c89ea80e5e6ba21addcfe12ae&narHash=sha256-1xzwwxygzs1cmysg97hzd285r7n1g1lwx5y1ar68gwq07a1rczmv";
      flake = false;
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";

      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "flake-utils";
      };
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";

      inputs = {
        flake-utils.follows = "flake-utils";
        gitignore.follows = "gitignore";
        nixpkgs-stable.follows = "nixpkgs";
        nixpkgs.follows = "nixpkgs-unstable";

        # Unused dependencies
        flake-compat.follows = "";
      };
    };

    foosteros = {
      url = "github:lilyinstarlight/foosteros";

      inputs = {
        flake-utils.follows = "flake-utils";
        impermanence.follows = "impermanence";
        nixpkgs-stable.follows = "nixpkgs";
        nixpkgs.follows = "nixpkgs-unstable";
        pre-commit-hooks-nix.follows = "pre-commit-hooks";
        sops-nix.follows = "sops-nix";
        flake-registry.follows = "flake-registry";

        # Unused dependencies
        crane.follows = "";
        disko.follows = "";
        envfs.follows = "";
        flake-compat.follows = "";
        flake-parts.follows = "";
        lanzaboote.follows = "";
        nix-alien.follows = "";
        nix-index-database.follows = "";
        rust-overlay.follows = "";
      };
    };
  };

  outputs = { self, ... }@inputs:
    with inputs;
    (nixpkgs-lib.lib.recursiveUpdate
      {
        lib = import ./lib;

        homeConfigurations = {
          pbp = self.lib.hmConfig {
            inherit (self.inputs) home-manager nixpkgs nixpkgs-unstable;
            inherit (self.outputs) homeModules;

            system = "aarch64-linux";
            username = "david";
            modules = [ ./homeConfigurations/pbp.nix ];
          };

          wsl = self.lib.hmConfig {
            inherit (self.inputs) home-manager nixpkgs nixpkgs-unstable;
            inherit (self.outputs) homeModules;


            username = "david";
            modules = [ ./homeConfigurations/wsl.nix ];
          };
        };

        homeModules = import ./homeModules;

        nixosConfigurations = {
          min = self.lib.defFlakeServer {
            inherit (self.inputs) flake-registry nixpkgs;

            modules = [ ./nixosConfigurations/min ];
          };

          dh-framework = self.lib.defFlakeWorkstation {
            inherit (self.inputs) flake-registry home-manager nixpkgs nixpkgs-unstable nix-index-database;
            inherit (self.outputs) nixosModules;

            overlays = [
              (_: _: {
                foosteros = import foosteros {
                  system = "x86_64-linux";

                  allowUnfree = true;
                };
              })
            ];

            cpuVendor = "intel";

            modules = [
              nixos-hardware.nixosModules.framework-12th-gen-intel
              sops-nix.nixosModules.sops
              impermanence.nixosModules.impermanence

              ./nixosConfigurations/dh-framework

              ({ config, lib, ... }: {
                home-manager.users."david" = self.lib.personalNixosHMConfig {
                  inherit (config.networking) hostName;
                  inherit (self.inputs) nixpkgs-unstable;
                  inherit (self.outputs) homeModules;
                  inherit lib;
                };
              })
            ];
          };

          ashley = self.lib.defFlakeServer {
            inherit (self.inputs) flake-registry nixpkgs;
            inherit (self.outputs) nixosModules;

            modules = [ ./nixosConfigurations/ashley ];
          };
        };

        nixosModules = import ./nixosModules;

        checks.x86_64-linux = import ./tests {
          inherit (self.inputs) home-manager nmt;
          inherit (self.outputs) nixosConfigurations;

          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        };
      }

      (flake-utils.lib.eachDefaultSystem (system: {
        checks.pre-commit-check = pre-commit-hooks.lib."${system}".run {
          src = gitignore.lib.gitignoreSource ./.;

          hooks = {
            deadnix.enable = true;
            nixpkgs-fmt.enable = true;
            statix.enable = true;
          };
        };

        devShells =
          let
            pkgs = import nixpkgs-unstable {
              inherit system;

              overlays = [ sops-nix.overlay ];
            };

            formatPackages = pkgs: with pkgs; [
              pre-commit
              nixpkgs-fmt
              deadnix
              statix
            ];

            sopsPackages = pkgs: with pkgs; [
              sops
              sops-init-gpg-key
              sops-import-keys-hook
            ];

            sopsPGPKeyDirs = [
              ./keys/hosts
              ./keys/users
            ];
          in
          {
            default = pkgs.mkShell {
              inherit (self.checks."${system}".pre-commit-check) shellHook;
              inherit sopsPGPKeyDirs;

              packages = (formatPackages pkgs) ++ (sopsPackages pkgs);
            };

            no-env = pkgs.mkShell {
              inherit sopsPGPKeyDirs;

              packages = (formatPackages pkgs) ++ (sopsPackages pkgs) ++ (with pkgs; [
                git
                gnupg
                pinentry-qt # FIXME: Should really have separate devShells for w/ desktop and w/o.
                neovim
              ]);

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
          };
      })));
}
