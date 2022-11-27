{ nixpkgs
, home-manager
, username
, nixpkgs-unstable ? null
, system ? "x86_64-linux"
, modules ? [ ]
}:
home-manager.lib.homeManagerConfiguration {
  inherit system username;

  pkgs = nixpkgs.legacyPackages."${system}";

  homeDirectory = "/home/${username}";

  stateVersion = "22.05";

  extraModules = modules;

  configuration = _: {
    programs.home-manager.enable = true;

    nixpkgs.overlays = [
      (_: super: {
        nixpkgs-unstable =
          if
            nixpkgs-unstable != null
          then
            import nixpkgs-unstable
              {
                inherit system;

                config.allowUnfree = true;
              }
          else
            super;
      })
    ];

    nix.registry = {
      nixpkgs.to = {
        type = "github";
        owner = "NixOS";
        repo = "nixpkgs";
        ref = nixpkgs.sourceInfo.rev;
      };

      nixpkgs-unstable.to = {
        type = "github";
        owner = "NixOS";
        repo = "nixpkgs";
        ref = if nixpkgs-unstable != null then nixpkgs-unstable.sourceInfo.rev else nixpkgs.sourceInfo.rev;
      };
    };
  };
}
