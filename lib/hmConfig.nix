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

    nixpkgs.overlays =
      if
        nixpkgs-unstable != null
      then
        [
          (_: _: {
            nixpkgs-unstable = import nixpkgs-unstable {
              inherit system;

              config.allowUnfree = true;
            };
          })
        ]
      else
        [
          (_: super: {
            nixpkgs-unstable = super;
          })
        ];
  };
}
