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
    # Package Sets
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-on-droid = {
      url = "github:t184256/nix-on-droid/release-22.11";

      inputs = {
        # home-manager.follows = "home-manager";
        # nixpkgs.follows = "nixpkgs";

        nix-formatter-pack.follows = "";
        nmd.follows = "";
      };
    };

    foosteros = {
      url = "github:lilyinstarlight/foosteros";

      inputs = {
        nixpkgs-stable.follows = "nixpkgs";
        nixpkgs.follows = "nixpkgs-unstable";

        # Unused dependencies
        disko.follows = "";
        flake-compat.follows = "";
        flake-parts.follows = "";
        flake-registry.follows = "";
        flake-utils.follows = "";
        home-manager.follows = "";
        impermanence.follows = "";
        lanzaboote.follows = "";
        nix-alien.follows = "";
        nix-index-database.follows = "";
        nixos-hardware.follows = "";
        pre-commit-hooks-nix.follows = "";
        sops-nix.follows = "";
      };
    };

    # Libraries
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";

    # NixOS Modules
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    impermanence.url = "github:nix-community/impermanence";
    nix-index-database.url = "github:cyntheticfox/nix-index-database-stable";

    disko = {
      url = "github:nix-community/disko";

      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";

      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      # TODO: Find another framework or something that doesn't use IFD
      url = "github:pta2002/nixvim/26626aa1b1610d3270b7a38cf610b0d1a237e3f9";

      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-utils.follows = "flake-utils";
        pre-commit-hooks.follows = "";
      };
    };

    # Extra flake utilities
    gitignore = {
      url = "github:hercules-ci/gitignore.nix";

      inputs.nixpkgs.follows = "nixpkgs-unstable";
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

    # MISC
    flake-registry = {
      url = "github:NixOS/flake-registry";
      flake = false;
    };

    nmt = {
      url = "gitlab:rycee/nmt";
      flake = false;
    };
  };

  outputs = { self, ... }@inputs:
    with inputs;
    (nixpkgs-lib.lib.recursiveUpdate
      {
        lib = import ./lib;

        homeConfigurations = {
          pbp = self.lib.mkHomeConfig {
            inherit (inputs) home-manager nixpkgs nixpkgs-unstable;
            inherit (self) homeModules;

            system = "aarch64-linux";
            hostname = "pbp";
            username = "cynthia";

            unstableHomeModules = [
              nixvim.homeManagerModules.nixvim
            ];
          };

          wsl = self.lib.mkHomeConfig {
            inherit (inputs) home-manager nixpkgs nixpkgs-unstable;
            inherit (self) homeModules;

            username = "cynthia";
            hostname = "wsl";

            unstableHomeModules = [
              nixvim.homeManagerModules.nixvim
            ];
          };
        };

        homeModules = import ./homeModules;

        nixosConfigurations = {
          min = self.lib.mkNixosServer {
            inherit (inputs) flake-registry nixpkgs;

            hostname = "nixos-minimal";
            domain = "";

            path = ./nixosConfigurations/min;

            modules = [ disko.nixosModules.disko ];
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

          cyn-framework = self.lib.mkNixosWorkstation {
            inherit (inputs) flake-registry home-manager nixpkgs nixpkgs-unstable nix-index-database;
            inherit (self) nixosModules;

            hostname = "cyn-framework";
            domain = "gh0st.network";

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

              ({ config, lib, ... }: {
                nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1u" ];

                home-manager.users."cynthia" = self.lib.mkNixosHomeConfig {
                  inherit (self) homeModules;
                  inherit lib;

                  unstableLib = nixpkgs-unstable.lib;

                  hostname = config.networking.hostName;

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

          ashley = self.lib.mkNixosServer {
            inherit (inputs) flake-registry nixpkgs;
            inherit (self) nixosModules;

            hostname = "ashley";
            domain = "gh0st.network";
          };
        };

        nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
          modules = [ ./nixOnDroidConfigurations/cyn-p7 ];
        };

        apps.x86_64-linux =
          let
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
          in
          {
            update-flake = {
              type = "app";

              # FIXME: Use patchShebangs
              program = builtins.toString (pkgs.writers.writeBash "update-flake" (builtins.readFile ./scripts/update-flake.sh));
            };

            build-and-diff-flake-system = {
              type = "app";

              program = builtins.toString (pkgs.writers.writeBash "build-and-diff-flake-system" (builtins.readFile ./scripts/build-and-diff-flake-system.sh));
            };
          };

        nixosModules = import ./nixosModules;

        checks.x86_64-linux = import ./tests {
          inherit (inputs) home-manager nmt;
          inherit (self) nixosConfigurations homeConfigurations;

          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        };
      }

      (flake-utils.lib.eachDefaultSystem (system: {
        checks.pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = gitignore.lib.gitignoreSource ./.;

          hooks = {
            actionlint.enable = true;
            deadnix.enable = true;
            editorconfig-checker.enable = true;
            nixpkgs-fmt.enable = true;
            nil.enable = true;
            shellcheck.enable = true;
            shfmt.enable = true;

            yamllint = {
              enable = true;

              files = "(^secrets.(yml|yaml)$)";
            };
          };
        };

        devShells =
          let
            pkgs = import nixpkgs-unstable {
              inherit system;

              overlays = [ sops-nix.overlays.default ];
            };

            inherit (pkgs) lib;

            formatPackages = with pkgs; [
              pre-commit
              nixpkgs-fmt
              editorconfig-checker
              deadnix
              statix
            ];

            editingPackages = with pkgs; [
              git
              git-crypt
              gnupg
              neovim
              pinentry
            ];

            sopsPackages = with pkgs; [
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
              inherit (self.checks.${system}.pre-commit-check) shellHook;
              inherit sopsPGPKeyDirs;

              packages = formatPackages ++ sopsPackages;
            };

            no-env = pkgs.mkShell {
              inherit sopsPGPKeyDirs;

              packages = formatPackages ++ sopsPackages ++ editingPackages;

              shellHook = lib.concatLines [
                self.checks.${system}.pre-commit-check.shellHook
                posixShellAliases
              ];
            };

            no-env-desktop = pkgs.mkShell {
              inherit sopsPGPKeyDirs;

              packages = formatPackages ++ sopsPackages ++ editingPackages
                ++ [ pkgs.pinentry-qt ];

              shellHook = lib.concatLines [
                self.checks.${system}.pre-commit-check.shellHook
                posixShellAliases
              ];
            };
          };
      })));
}
