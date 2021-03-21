{
  description = "Personal dotfiles";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/master";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }@inputs: {
    nixosModules.dotfiles = ({ config, ... }: {
      home.file = {
        ".profile".source = ./.profile;
        ".bashrc".source = ./.bashrc;
        ".bash_profile".source = ./.bash_profile;
        ".editorconfig".source = ./.editorconfig;
        ".zshrc".source = ./.zshrc;

        ".config" = {
          source = ./.config;
          recursive = true;
        };

        ".ssh" = {
          source = ./.ssh;
          recursive = true;
        };

        ".gnupg" = {
          source = ./.gnupg;
          recursive = true;
        };

      };
    });
  };
}
