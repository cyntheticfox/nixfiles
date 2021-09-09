{
  description = "Personal dotfiles";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }@inputs:
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
      nixosModules.dotfiles = ({ config, ... }: {
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
}
