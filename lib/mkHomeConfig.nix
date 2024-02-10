{ nixpkgs
, nixpkgs-unstable
, home-manager
, homeModules
, unstableHomeModules
, username
, hostname
, stateVersion
, path ? ../homeConfigurations/${hostname}
, system ? "x86_64-linux"
, allowUnfree ? true
, specialArgs ? { }
}:

assert builtins.isAttrs homeModules || builtins.isList homeModules;

let
  inherit (nixpkgs) lib;

  unstablePkgs = import nixpkgs-unstable {
    inherit system;

    config.allowUnfree = true;
  };

  unstable-overlay = _: _: {
    nixpkgs-unstable = unstablePkgs;
  };

  collectModules =
    modules:
    if
      builtins.isAttrs modules
    then
      lib.collect builtins.isFunction modules
    else
      modules;

  overrideModulePkgs =
    module:
    { pkgs, ... }@args:
    module (args // {
      inherit (nixpkgs-unstable) lib;

      pkgs = unstablePkgs;
    });
in
home-manager.lib.homeManagerConfiguration {
  extraSpecialArgs = specialArgs;

  pkgs = import nixpkgs {
    inherit system;

    config.allowUnfree = allowUnfree;

    overlays = [ unstable-overlay ];
  };

  modules = [
    path
    {
      home = {
        inherit username stateVersion;

        homeDirectory = "/home/${username}";
      };

      programs.home-manager.enable = true;

      nixpkgs.config.allowUnfree = allowUnfree;
      nixpkgs.overlays = [ unstable-overlay ];

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
          ref = nixpkgs-unstable.sourceInfo.rev;
        };
      };
    }
  ] ++ collectModules homeModules
  ++ builtins.map overrideModulePkgs (collectModules unstableHomeModules);
}
