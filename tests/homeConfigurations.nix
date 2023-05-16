# :: { pkgs :: AttrSet, homeConfigurations :: AttrSet } -> AttrSet
{ pkgs, homeConfigurations, ... }:

assert builtins.isAttrs homeConfigurations;

with pkgs;

let
  # type NixosConfig = AttrSet # too much work to figure out right now

  # hasTestableSystem :: HomeConfig -> Bool
  hasTestableSystem = builtins.hasAttr "activationPackage";

  # isBuildableOnHost :: NixosConfig -> Bool
  isBuildableOnHost =
    homeConfig:
    homeConfig.pkgs.stdenv.hostPlatform.system == pkgs.stdenv.hostPlatform.system;

  # isTestableOnHost :: NixosConfig -> Bool
  isTestableOnHost = _: homeConfig:
    hasTestableSystem homeConfig && isBuildableOnHost homeConfig;

  # mkConfigListItem :: HomeConfig -> AttrSet
  mkConfigListItem = name: homeConfig: lib.nameValuePair "host-test-${name}" homeConfig.activationPackage;
in
lib.mapAttrs' mkConfigListItem (lib.filterAttrs isTestableOnHost homeConfigurations)
