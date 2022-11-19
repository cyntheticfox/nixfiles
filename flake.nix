{
  description = "Personal dotfiles";

  nixConfig = {
    extra-experimental-features = "nix-command flakes ca-derivations";
    extra-substituters =
      "https://cache.nixos.org https://nix-community.cachix.org";
    extra-trusted-public-keys =
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    flake-utils.url = "github:numtide/flake-utils";

    nix-index-database.url = "github:houstdav000/nix-index-database-stable";

    impermanence.url = "github:nix-community/impermanence";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, ... }@inputs:
    with inputs;
    {
      lib = import ./lib;

      homeConfigurations = {
        dh-framework = self.lib.hmConfig {
          inherit inputs;

          username = "david";
          modules = [ ./homeConfigurations/dh-framework.nix ];
        };

        pbp = self.lib.hmConfig {
          inherit inputs;

          username = "david";
          system = "aarch64-linux";
          modules = [ ./homeConfigurations/pbp.nix ];
        };

        wsl = self.lib.hmConfig {
          inherit inputs;

          username = "david";
          modules = [ ./homeConfigurations/wsl.nix ];
        };
      };

      homeModules = import ./homeModules;

      nixosConfigurations = {
        min = self.lib.defFlakeServer {
          inherit (self.inputs) nixpkgs;

          modules = [ ./nixosConfigurations/min ];
        };

        dh-framework = self.lib.defFlakeWorkstation {
          inherit (self.inputs) home-manager nixpkgs nixpkgs-unstable;

          cpuVendor = "intel";

          modules = [
            nixos-hardware.nixosModules.framework
            sops-nix.nixosModules.sops
            impermanence.nixosModules.impermanence

            ./nixosConfigurations/dh-framework

            ({ config, lib, ... }: {
              home-manager.users."david" = self.lib.personalNixosHMConfig {
                inherit lib;
                inherit (config.networking) hostName;
                inherit (self.inputs) nixpkgs-unstable;
                inherit (self.outputs) homeModules;
              };
            })
          ];
        };

        ashley = self.lib.defFlakeServer {
          inherit (self.inputs) nixpkgs;

          modules = [ ./nixosConfigurations/ashley ];
        };
      };

      checks.x86_64-linux = (nixpkgs.lib.genAttrs (builtins.attrNames self.nixosConfigurations) (name: self.nixosConfigurations."${name}".config.system.build.toplevel)) //
      (import ./tests {
        inherit home-manager;

        pkgs = nixpkgs.legacyPackages.x86_64-linux;
      });

    } // flake-utils.lib.eachDefaultSystem (system: {
      checks.pre-commit-check = pre-commit-hooks.lib."${system}".run {
        src = ./.;
        hooks = {
          deadnix.enable = true;
          nixpkgs-fmt.enable = true;
          statix.enable = true;
        };
      };
      devShells = {
        default =
          let
            pkgs = import nixpkgs-unstable {
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
              deadnix
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
            pkgs = import nixpkgs-unstable {
              inherit system;
              overlays = [ sops-nix.overlay ];
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
              deadnix
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
      };
    });
}
