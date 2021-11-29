{ pkgs
, outpkgs ? pkgs
, allowUnfree ? (!(builtins.getEnv "NIXOS_EXCLUDE_UNFREE" == "1"))
, isOverlay ? false
, ...
}:

with pkgs;

let mypkgs =
  { } // (lib.optionalAttrs allowUnfree {
    hyperchroma = callPackage ./hyperchroma { };
  });

in mypkgs
