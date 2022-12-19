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

{ pkgs, nixosConfigurations, ... }:

assert builtins.isAttrs nixosConfigurations;

with pkgs;

let
  testHostModules = [
    {
      nixpkgs.config.allowUnfree = false;
    }
  ];

  mkTestConfig = cfg: (cfg // {
    modules = testHostModules ++ (cfg.modules or [ ]);
  });

  mkTestSystem = cfg: (mkTestConfig cfg).config.system.build.toplevel;

  mkTestInstaller = cfg: (mkTestConfig cfg).config.system.build.installer;

  hasTestableSystem = lib.attrsets.hasAttrByPath [ "config" "system" "build" "toplevel" ];

  isBuildableOnHost = cfg: cfg.pkgs.stdenv.hostPlatform.system == pkgs.stdenv.hostPlatform.system;

  isTestableOnHost = cfg: (hasTestableSystem cfg) && (isBuildableOnHost cfg);

  hasInstaller = lib.attrsets.hasAttrByPath [ "config" "system" "build" "installer" ];

  mkConfigListItem = cfg: { "host-test-${cfg.config.networking.hostName}" = mkTestSystem cfg; } // (if hasInstaller cfg then { "installer-test-${cfg.config.networking.hostName}" = mkTestInstaller cfg; } else { });
in
builtins.foldl' (lhs: rhs: lhs // rhs) { } (lib.lists.flatten (builtins.map mkConfigListItem (lib.attrsets.collect isTestableOnHost nixosConfigurations)))
