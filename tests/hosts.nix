# The MIT License (MIT)
#
# Copyright (c) 2020-2022, Lily Foster <lily@lily.flowers>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# :: { pkgs :: AttrSet, nixosConfigurations :: AttrSet } -> AttrSet
{ pkgs, nixosConfigurations, ... }:

assert builtins.isAttrs nixosConfigurations;

with pkgs;

let
  # type NixosConfig = AttrSet # too much work to figure out right now

  testHostModules = [
    {
      nixpkgs.config.allowUnfree = false;
    }
  ];

  # hasTestableSystem :: NixosConfig -> NixosConfig
  hasTestableSystem = lib.attrsets.hasAttrByPath [ "config" "system" "build" "toplevel" ];

  # hasInstaller :: NixosConfig -> NixosConfig
  hasInstaller = lib.attrsets.hasAttrByPath [ "config" "system" "build" "installer" ];

  # isBuildableOnHost :: NixosConfig -> Bool
  isBuildableOnHost = cfg:
    cfg.pkgs.stdenv.hostPlatform.system == pkgs.stdenv.hostPlatform.system;

  # isTestableOnHost :: NixosConfig -> Bool
  isTestableOnHost = cfg:
    hasTestableSystem cfg && isBuildableOnHost cfg;

  # mkTestConfig :: NixosConfig -> NixosConfig
  mkTestConfig = cfg:
    cfg // {
      modules = testHostModules ++ (cfg.modules or [ ]);
    };

  # mkConfigListItem :: NixosConfig -> AttrSet
  mkConfigListItem = cfg:
    {
      "host-test-${cfg.config.networking.hostName}" = (mkTestConfig cfg).config.system.build.toplevel;
    } // lib.attrsets.optionalAttrs (hasInstaller cfg) {
      "installer-test-${cfg.config.networking.hostName}" = (mkTestConfig cfg).config.system.build.installer;
    };

  # mergeAttrsList :: [AttrSet] -> AttrSet
  mergeAttrsList = builtins.foldl' lib.trivial.mergeAttrs { };
in
mergeAttrsList (builtins.map mkConfigListItem (lib.attrsets.collect isTestableOnHost nixosConfigurations))
