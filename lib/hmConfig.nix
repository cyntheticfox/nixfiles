{ nixpkgs
, home-manager
, username
, system ? "x86_64-linux"
, nixpkgs-unstable ? null
, allowUnfree ? true
, modules ? [ ]
}:
let
  unstable-overlay = _: super: {
    nixpkgs-unstable =
      if
        nixpkgs-unstable != null
      then
        import nixpkgs-unstable
          {
            config.allowUnfree = true;
          }
      else
        super;
  };
in
home-manager.lib.homeManagerConfiguration {
  pkgs = import nixpkgs {
    inherit system;

    config.allowUnfree = allowUnfree;

    overlays = [ unstable-overlay ];
  };

  modules = [
    {
      inherit username;

      home.stateVersion = "22.11";
      homeDirectory = "/home/${username}";
    }
    { programs.home-manager.enable = true; }
    {
      nixpkgs.allowUnfree = allowUnfree;
      nixpkgs.overlays = [ unstable-overlay ];
    }
    {
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
    }
  ] ++ modules;
}
