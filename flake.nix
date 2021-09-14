{
  description = "Personal dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }@inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem
      (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          devShell =
            pkgs.mkShell {
              nativeBuildInputs = with pkgs; [
                shfmt
                shellcheck
                vim-vint
              ];
            };
        }) // {
      lib = {
        hmConfig = { system ? "x86_64-linux", modules ? [ ], extraArgs ? { } }:
          home-manager.lib.homeManagerConfiguration {
            system = system;
            username = "david";
            homeDirectory = "/home/${username}";

            configuration = { pkgs, lib, ... }: {
              imports = [
                extraArgs
              ] ++ modules;
            };
        };

        defFlakeSystem = { system ? "x86_64-linux", modules ? [ ], extraArgs ? { } }:
          nixpkgs.lib.nixosSystem {
            system = system;
            modules = [
              # Add home-manager to all configs
              ./nixos/config/base.nix
              home-manager.nixosModules.home-manager
            ] ++ modules;
            extraArgs = {
              inherit self;
              inherit (self) inputs outputs;
            } // extraArgs;
          };
      };

      nixosModules = {
        dh-laptop2.imports = [
          {
            nixpkgs.overlays = [ neovim-nightly-overlay.overlay ];
          }
          ./home-manager/hosts/dh-laptop2/home.nix
        ];
      };

      homeConfigurations = {
        wsl = self.lib.hmConfig {
          modules = [
            ./home-manager/hosts/wsl/home.nix
          ];
          extraConfig = {
            nixpkgs.overlays = [ neovim-nightly-overlay.overlay ];
          };
        };

        pbp = self.lib.hmConfig {
          system = "aarch64-linux";
          modules = [
            ./home-manager/hosts/pbp/home.nix
          ];
          extraConfig = {
            nixpkgs.overlays = [ neovim-nightly-overlay.overlay ];
          };
        };
      };

      nixosConfigurations = {
        dh-laptop2 = self.lib.defFlakeSystem {
          modules = [
            ./nixos/hosts/dh-laptop2/configuration.nix
          ];
        };

        ashley = self.lib.defFlakeSystem {
          modules = [
            ./nixos/hosts/ashley/configuration.nix
          ];
        };
      };
    };
}
