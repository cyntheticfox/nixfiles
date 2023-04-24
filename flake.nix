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

    nix-index-database.url = "github:cyntheticfox/nix-index-database-stable";

    disko = {
      url = "github:nix-community/disko";

      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

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

    nixvim = {
      url = "github:pta2002/nixvim";

      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-utils.follows = "flake-utils";
        pre-commit-hooks.follows = "pre-commit-hooks";
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
        disko.follows = "disko";
        flake-registry.follows = "flake-registry";
        flake-utils.follows = "flake-utils";
        home-manager.follows = "home-manager";
        impermanence.follows = "impermanence";
        nixos-hardware.follows = "nixos-hardware";
        nixpkgs-stable.follows = "nixpkgs";
        nixpkgs.follows = "nixpkgs-unstable";
        pre-commit-hooks-nix.follows = "pre-commit-hooks";
        sops-nix.follows = "sops-nix";

        # Unused dependencies
        crane.follows = "";
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
            username = "cynthia";
            modules = [ ./homeConfigurations/pbp.nix ];
          };

          wsl = self.lib.hmConfig {
            inherit (self.inputs) home-manager nixpkgs nixpkgs-unstable;
            inherit (self.outputs) homeModules;


            username = "cynthia";
            modules = [ ./homeConfigurations/wsl.nix ];
          };
        };

        homeModules = import ./homeModules;

        nixosConfigurations = {
          min = self.lib.defFlakeServer {
            inherit (self.inputs) flake-registry nixpkgs;

            modules = [
              ./nixosConfigurations/min

              disko.nixosModules.disko
            ];
          };

          hcloud-init = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";

            modules = [
              ./nixosConfigurations/min

              disko.nixosModules.disko

              ({ modulesPath, ... }: {
                imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

                services.openssh.enable = true;
                users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGhQjUo/lBb2+WUaU1grNi88Yi+WdhEAy8p6CRcc6DTE cynthia@cyn-framework" ];
                system.stateVersion = "22.11";
              })
            ];
          };

          cyn-framework = self.lib.defFlakeWorkstation {
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

              ./nixosConfigurations/cyn-framework

              ({ config, lib, ... }: {
                home-manager.users."cynthia" = self.lib.personalNixosHMConfig {
                  inherit (config.networking) hostName;
                  inherit (self.outputs) homeModules;
                  inherit lib;

                  unstableLib = nixpkgs-unstable.lib;

                  unstablePkgs = import nixpkgs-unstable {
                    system = "x86_64-linux";

                    config.allowUnfree = true;
                  };

                  unstableHomeModules = [
                    nixvim.homeManagerModules.nixvim
                    impermanence.nixosModules.home-manager.impermanence
                  ];
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

        apps.x86_64-linux.update-flake =
          let
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
          in
          {
            type = "app";

            # FIXME: Use patchShebangs
            program = builtins.toString (pkgs.writers.writeBash "update-flake" (builtins.readFile ./scripts/update-flake.sh));
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

              overlays = [ sops-nix.overlays.default ];
            };

            formatPackages = pkgs: with pkgs; [
              pre-commit
              nixpkgs-fmt
              deadnix
              statix
            ];

            editingPackages = pkgs: with pkgs; [
              git
              gnupg
              neovim
              pinentry
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

            posixShellAliases = ''
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
          in
          {
            default = pkgs.mkShell {
              inherit (self.checks."${system}".pre-commit-check) shellHook;
              inherit sopsPGPKeyDirs;

              packages = (formatPackages pkgs) ++ (sopsPackages pkgs);
            };

            no-env = pkgs.mkShell {
              inherit sopsPGPKeyDirs;

              packages = formatPackages pkgs
                ++ sopsPackages pkgs
                ++ editingPackages pkgs;

              shellHook = builtins.concatStringsSep "\n" [
                self.checks."${system}".pre-commit-check.shellHook
                posixShellAliases
              ];
            };

            no-env-desktop = pkgs.mkShell {
              inherit sopsPGPKeyDirs;

              packages = formatPackages pkgs
                ++ sopsPackages pkgs
                ++ editingPackages pkgs
                ++ [ pkgs.pinentry-qt ];

              shellHook = builtins.concatStringsSep "\n" [
                self.checks."${system}".pre-commit-check.shellHook
                posixShellAliases
              ];
            };
          };
      })));
}
