{ self
, username
, nixpkgs-unstable ? null
, system ? "x86_64-linux"
, modules ? [ ]
}:
self.inputs.home-manager.lib.homeManagerConfiguration {
  inherit system username;

  homeDirectory = "/home/${username}";

  configuration = _: {
    imports = modules ++ (builtins.attrValues self.outputs.homeModules);

    home.stateVersion = "22.05";

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
