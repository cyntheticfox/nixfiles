{
  description = "Personal dotfiles";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/master";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }@inputs:

    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages.dotfiles = with pkgs;
          stdenv.mkDerivation {
            name = "dotfiles";
            src = ./.;
            installPhase = ''
              mkdir $out
              find $src \
                -mindepth 1 \
                -maxdepth 1 \
                -not -name $src \
                -not -name ".git" \
                -not -name "flake.nix" \
                -not -name "flake.lock" \
                -not -name "install.sh" \
                -not -name ".gitattributes" \
                -not -name ".gitignore" \
                -not -name "LICENSE" \
                -not -name "README.md" \
                -exec cp -r {} $out \;
            '';
          };

        defaultPackage = packages.dotfiles;
      });
}
