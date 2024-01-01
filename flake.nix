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
      url = "github:t184256/nix-on-droid/release-23.05";

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

    devshell = {
      url = "github:numtide/devshell";

      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
      # url = "github:pta2002/nixvim/26626aa1b1610d3270b7a38cf610b0d1a237e3f9";
      url = "github:pta2002/nixvim";

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
                    sops-nix.homeManagerModules.sops
                    nixvim.homeManagerModules.nixvim
                    impermanence.nixosModules.home-manager.impermanence
                  ];
                };
              })
            ];
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
            statix.enable = true;

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
              nixpkgs-fmt
              pre-commit
              sops
              sops-init-gpg-key
              ssh-to-age
              ssh-to-pgp
              statix
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
