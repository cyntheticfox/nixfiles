# A function to return the home-manager config suitable for use in NixOS
{ hostName
, homeModules
, lib
, inputs
}:

# assert builtins.hasAttr "networking.hostName" config;
assert lib.assertMsg (builtins.isAttrs homeModules || builtins.isList homeModules) "HomeModules should be an attrset of module functions or a list of attrsets";
assert builtins.hasAttr "collect" lib;
assert builtins.hasAttr "optional" lib;
assert builtins.hasAttr "optionalString" lib;
assert builtins.isAttrs inputs;

let
  # homeModuleList ::
  homeModuleList = if builtins.isAttrs homeModules then lib.collect builtins.isFunction homeModules else homeModules;

  # data homeModulePaths :: [AttrPath]
  homeModulePaths = [
    [ "nixosModules" "home-manager" ] # Seen in impermanence
    [ "homeModules" ] # My convention
    [ "homeManagerModules" ] # Seen in nixvim and foosteros
  ];

  # hasHomeModule :: AttrSet -> bool
  hasHomeModule = input: builtins.any (path: lib.hasAttrByPath path input) homeModulePaths;

  # getHomeModule :: AttrSet -> (AttrSet -> AttrSet)
  getHomeModule = input:
    let
      # getHomeModulePath :: AttrSet -> path
      getHomeModulePath = input: lib.flatten (builtins.filter (path: lib.hasAttrByPath path input) homeModulePaths);
    in
    lib.getAttrFromPath (getHomeModulePath input) input;

  externalModules = inputs: builtins.map getHomeModule (builtins.filter hasHomeModule (builtins.attrValues inputs));

  externalModuleNames = builtins.filter (x: hasHomeModule inputs."${x}") (builtins.attrNames inputs);
  externalModuleList = externalModules inputs;

  modules = externalModuleList ++ homeModuleList;
in
_: {
  imports = [ (../. + "/homeConfigurations/${hostName}.nix") ] ++ modules;

  programs.home-manager.enable = true;

  home = {
    stateVersion = "22.11";
    sessionVariables."ON_NIXOS" = "1";
  };

  extraSpecialArgs.externalModuleNames = externalModuleNames;
}
