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
                cargo
                fish
                nixpkgs-fmt
                rnix-lsp
                proselint
                shfmt
                shellcheck
                vim-vint
              ];
            };
        }) // {
      lib = {
        hmConfig = { system ? "x86_64-linux", modules ? [ ], extraArgs ? { } }: (home-manager.lib.homeManagerConfiguration {
          system = system;
          username = "david";
          homeDirectory = "/home/${username}";

          configuration = { pkgs, lib, ... }: {
            imports = [
              self.nixosModules.dotfiles
              ./home-manager/config/base.nix
              extraArgs
            ] ++ modules;
          };
        });

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
          self.nixosModules.dotfiles
          ./home-manager/config/base.nix
          ./home-manager/config/server.nix
          ./home-manager/config/dev.nix
          ./home-manager/config/desktop.nix
          ./home-manager/config/work.nix
          ./home-manager/modules/desktop-chat.nix
          ./home-manager/modules/documents.nix
          ./home-manager/modules/games.nix
          ./home-manager/modules/libvirt.nix
          ./home-manager/modules/kubernetes.nix
          ./home-manager/modules/music.nix
          ./home-manager/modules/music-editing.nix
          ./home-manager/modules/openshift.nix
          ./home-manager/modules/postman.nix
          ./home-manager/modules/video.nix
          ./home-manager/modules/video-editing.nix
        ];
        dotfiles = ({ config, ... }: {
          home.file = {
            ".profile".source = ./home/.profile;
            ".bashrc".source = ./home/.bashrc;
            ".bash_profile".source = ./home/.bash_profile;
            ".editorconfig".source = ./home/.editorconfig;
            ".zshrc".source = ./home/.zshrc;

            ".config" = {
              source = ./home/.config;
              recursive = true;
            };

            ".ssh" = {
              source = ./home/.ssh;
              recursive = true;
            };

            ".gnupg" = {
              source = ./home/.gnupg;
              recursive = true;
            };
          };
        });
      };

      homeConfigurations = {
        wsl = self.lib.hmConfig {
          modules = [
            ./home-manager/config/server.nix
            ./home-manager/config/dev.nix
          ];
          extraConfig = {
            nixpkgs.overlays = [ neovim-nightly-overlay.overlay ];
          };
        };
        pbp = self.lib.hmConfig {
          system = "aarch64-linux";
          modules = [
            ./home-manager/config/server.nix
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
