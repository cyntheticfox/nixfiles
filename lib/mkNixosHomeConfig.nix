# A function to return the home-manager config suitable for use in NixOS
{
  hostname,
  lib,
  unstablePkgs,
  unstableLib,
  stateVersion,
  homeModules ? [ ],
  unstableHomeModules ? [ ],
  path ? ../homeConfigurations/${hostname},
}:

assert builtins.isAttrs homeModules || builtins.isList homeModules;
assert builtins.hasAttr "collect" lib;

let
  collectModules =
    modules: if builtins.isAttrs modules then lib.collect builtins.isFunction modules else modules;

  overrideModulePkgs =
    module:
    { pkgs, ... }@args:
    module (
      args
      // {
        lib = unstableLib;
        pkgs = unstablePkgs;
      }
    );
in
_: {
  imports =
    [ path ]
    ++ collectModules homeModules
    ++ builtins.map overrideModulePkgs (collectModules unstableHomeModules);

  programs.home-manager.enable = true;

  home = {
    inherit stateVersion;

    sessionVariables."ON_NIXOS" = "1";
  };
}
