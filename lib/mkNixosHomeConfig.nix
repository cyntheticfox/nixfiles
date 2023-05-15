# A function to return the home-manager config suitable for use in NixOS
{ hostName
, homeModules
, lib
, unstableHomeModules
, unstablePkgs
, unstableLib
}:

# assert builtins.hasAttr "networking.hostName" config;
assert builtins.isAttrs homeModules || builtins.isList homeModules;
assert builtins.hasAttr "collect" lib;

let
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
      lib = unstableLib;
      pkgs = unstablePkgs;
    });
in
_: {
  imports = [ (../. + "/homeConfigurations/${hostName}.nix") ]
    ++ collectModules homeModules
    ++ builtins.map overrideModulePkgs (collectModules unstableHomeModules);

  programs.home-manager.enable = true;

  home = {
    stateVersion = "22.11";
    sessionVariables."ON_NIXOS" = "1";
  };
}
