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
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-23.11";

      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
        nixpkgs-for-bootstrap.follows = "nixpkgs";

        # Unused dependencies
        nix-formatter-pack.follows = "";
        nixpkgs-docs.follows = "";
        nmd.follows = "";
      };
    };

    foosteros = {
      url = "github:lilyinstarlight/foosteros";

      inputs = {
        nixpkgs-stable.follows = "nixpkgs";
        nixpkgs.follows = "nixpkgs-unstable";
        flake-parts.follows = "flake-parts";

        # Unused dependencies
        disko.follows = "";
        flake-compat.follows = "";
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
    nixpkgs-lib.url = "github:nixos/nixpkgs/nixos-unstable?dir=lib";

    flake-utils = {
      url = "github:numtide/flake-utils";

      inputs.systems.follows = "systems";
    };

    devshell = {
      url = "github:numtide/devshell";

      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-utils.follows = "flake-utils";
      };
    };

    terranix = {
      url = "github:terranix/terranix";

      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-utils.follows = "flake-utils";

        # Unused dependencies
        terranix-examples.follows = "";
        bats-support.follows = "";
        bats-assert.follows = "";
      };
    };

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
      url = "github:nix-community/home-manager/release-23.11";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      # TODO: Find another framework or something that doesn't use IFD
      # url = "github:nix-community/nixvim/26626aa1b1610d3270b7a38cf610b0d1a237e3f9";
      url = "github:nix-community/nixvim";

      inputs = {
        devshell.follows = "devshell";
        flake-parts.follows = "flake-parts";
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs-unstable";
        pre-commit-hooks.follows = "git-hooks";

        # Unused Inputs
        flake-compat.follows = "";
        nix-darwin.follows = "";
      };
    };

    # Extra flake utilities
    gitignore = {
      url = "github:hercules-ci/gitignore.nix";

      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";

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
      # url = "sourcehut:~rycee/nmt"; # TODO: fix
      url = "git+https://git.sr.ht/~rycee/nmt";
      flake = false;
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };

    systems.url = "github:nix-systems/default-linux";
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
            stateVersion = "23.11";

            unstableHomeModules = [
              nixvim.homeManagerModules.nixvim
            ];
          };

          wsl = self.lib.mkHomeConfig {
            inherit (inputs) home-manager nixpkgs nixpkgs-unstable;
            inherit (self) homeModules;

            username = "cynthia";
            hostname = "wsl";
            stateVersion = "23.11";

            unstableHomeModules = [
              nixvim.homeManagerModules.nixvim
            ];
          };
        };

        homeModules = import ./homeModules;

        nixosConfigurations = {
          yukari = self.lib.mkNixosWorkstation {
            inherit (inputs) flake-registry home-manager nixpkgs nixpkgs-unstable nix-index-database;
            inherit (self) nixosModules;

            hostname = "yukari";
            domain = "gh0st.internal";
            stateVersion = "23.11";

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
                    sops-nix.homeManagerModules.sops
                    nixvim.homeManagerModules.nixvim
                    impermanence.nixosModules.home-manager.impermanence
                  ];

                  stateVersion = "23.11";
                };
              })
            ];
          };

          min = self.lib.mkNixosServer {
            inherit (inputs) flake-registry nixpkgs;

            hostname = "nixos-minimal";
            domain = "";
            stateVersion = "23.11";
            path = ./nixosConfigurations/min;
            modules = [ disko.nixosModules.disko ];
          };
        };

        nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
          system.stateVersion = "23.11";
          modules = [ ./nixOnDroidConfigurations/ran ];
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
        checks.pre-commit-check = git-hooks.lib.${system}.run {
          src = gitignore.lib.gitignoreSource ./.;

          hooks = {
            actionlint.enable = true;
            check-added-large-files.enable = true;
            deadnix.enable = true;
            detect-private-keys.enable = true;
            editorconfig-checker.enable = true;
            fix-byte-order-marker.enable = true;
            nixpkgs-fmt.enable = true;
            nil.enable = true;
            shfmt.enable = true;
            statix.enable = true;

            typos = {
              enable = true;

              files = "(^.asc$)";
            };

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

              overlays = [
                devshell.overlays.default
                sops-nix.overlays.default
              ];
            };

            packages = with pkgs; [
              age
              deadnix
              editorconfig-checker
              hcloud
              nixpkgs-fmt
              pre-commit
              sops
              sops-init-gpg-key
              ssh-to-age
              ssh-to-pgp
              statix
              typos
            ];

            commands = [
              { package = pkgs.git-crypt; }
              { package = pkgs.gnupg; }
              { package = pkgs.pinentry; }
              {
                name = "g";
                package = pkgs.git;
              }
              {
                name = "ga";
                package = pkgs.git;
                command = "git add";
              }
              {
                name = "gaa";
                package = pkgs.git;
                command = "git add --all";
              }
              {
                name = "gc";
                package = pkgs.git;
                command = "git commit";
              }
              {
                name = "gca";
                package = pkgs.git;
                command = "git commit --all";
              }
              {
                name = "gcmsg";
                package = pkgs.git;
                command = "git commit -m";
              }
              {
                name = "gd";
                package = pkgs.git;
                command = "git diff";
              }
              {
                name = "gl";
                package = pkgs.git;
                command = "git pull";
              }
              {
                name = "gsb";
                package = pkgs.git;
                command = "git status -sb";
              }
              {
                name = "n";
                package = pkgs.nix;
              }
              {
                name = "nfu";
                package = pkgs.nix;
                command = "nix flake update";
              }
              {
                name = "nosswf";
                command = "nixos-rebuild switch --use-remote-sudo --flake .";
              }
              {
                name = "v";
                package = pkgs.neovim;
              }
            ];
          in
          {
            default = pkgs.devshell.mkShell {
              inherit packages;

              devshell = {
                startup.pre-commit.text = self.checks.${system}.pre-commit-check.shellHook;
                motd = "";
                meta.description = ''
                  Config for systems already set up
                '';
              };
            };

            no-env = pkgs.devshell.mkShell {
              inherit commands packages;

              devshell = {
                startup.pre-commit.text = self.checks.${system}.pre-commit-check.shellHook;

                meta.description = ''
                  Config for systems NOT already set up
                '';
              };
            };

            no-env-desktop = pkgs.devshell.mkShell {
              inherit commands;

              packages = packages ++ [ pkgs.pinentry-qt ];

              devshell = {
                startup.pre-commit.text = self.checks.${system}.pre-commit-check.shellHook;

                meta.description = ''
                  Config for systems NOT already set up
                '';
              };
            };
          };
      })));
}
