{
  description = "Personal dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:Nixos/nixpkgs/master";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.master.follows = "nixpkgs-master";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }@inputs:
    with inputs;
    {
      lib = {
        hmConfig =
          { system ? "x86_64-linux", modules ? [ ], extraArgs ? { } }:
          home-manager.lib.homeManagerConfiguration {
            inherit system;
            username = "david";
            homeDirectory = "/home/${username}";

            configuration = { pkgs, lib, ... }: {
              imports = [ extraArgs ] ++ modules;
            };
          };

        defFlakeSystem =
          { system ? "x86_64-linux", modules ? [ ], extraArgs ? { } }:
          nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              # Add home-manager to all configurations
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
            nixpkgs.overlays = [
              neovim-nightly-overlay.overlay
              nixpkgs-wayland.overlay
            ];
          }
          ./home-manager/hosts/dh-laptop2/home.nix
        ];
      };

      homeConfigurations = {
        wsl = self.lib.hmConfig {
          modules = [ ./home-manager/hosts/wsl/home.nix ];
          extraConfig = {
            nixpkgs.overlays = [ neovim-nightly-overlay.overlay ];
          };
        };

        pbp = self.lib.hmConfig {
          system = "aarch64-linux";
          modules = [ ./home-manager/hosts/pbp/home.nix ];
          extraConfig = {
            nixpkgs.overlays = [ neovim-nightly-overlay.overlay ];
          };
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
    };
}
