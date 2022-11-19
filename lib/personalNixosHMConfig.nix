# A function to return the home-manager config suitable for use in NixOS
{ hostName
, homeModules
, lib
, ...
}:

# assert builtins.hasAttr "networking.hostName" config;
assert builtins.isAttrs homeModules || builtins.isList homeModules;
assert builtins.hasAttr "collect" lib;

let
  modules = if builtins.isAttrs homeModules then lib.collect builtins.isFunction homeModules else homeModules;
in
_: {
  imports = [ (../. + "/homeConfigurations/${hostName}.nix") ] ++ modules;

  programs.home-manager.enable = true;

  home.stateVersion = "22.05";

  home.sessionVariables."ON_NIXOS" = "1";
}
