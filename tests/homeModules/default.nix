# Derived from https://github.com/nix-community/home-manager
#
# MIT License
#
# Copyright (c) 2017-2022 Home Manager contributors
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

{ pkgs ? import <nixpkgs> { }, home-manager }:

let
  lib = pkgs.lib.extend
    (_: super: {
      inherit (home-manager.lib) hm;

      literalExpression = super.literalExpression or super.literalExample;
      literalDocBook = super.literalDocBook or super.literalExample;
    });

  nmt = pkgs.fetchFromGitLab {
    owner = "rycee";
    repo = "nmt";
    rev = "d83601002c99b78c89ea80e5e6ba21addcfe12ae";
    sha256 = "1xzwwxygzs1cmysg97hzd285r7n1g1lwx5y1ar68gwq07a1rczmv";
  };

  modules = (import (home-manager.outPath + "/modules/modules.nix") {
    inherit lib pkgs;

    check = false;
    useNixpkgsModule = false;
  }) ++
  (import ../../homeModules/modules-list.nix) ++ [
    {
      # Fix impurities
      xdg.enable = true;
      home.username = "hm-user";
      home.homeDirectory = "/home/hm-user";

      # Test docs separately
      manual.manpages.enable = false;

      imports = [ (home-manager.outPath + "/tests/asserts.nix") ];
    }
  ];

  # inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in
import nmt {
  inherit lib pkgs modules;
  testedAttrPath = [ "home" "activationPackage" ];
  tests = builtins.foldl' (a: b: a // (import b)) { } [
    ./sys
  ];
}
