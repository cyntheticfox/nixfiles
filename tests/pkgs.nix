{ pkgs, ... }:

with pkgs;

let
  ifSupported = drv: test: if drv.meta.unsupported then "skip" else test;
in

lib.filterAttrs (name: value: value != "skip") {
  # hyperchroma = ifSupported hyperchroma (runCommandNoCC "test-hyperchroma" {
  #   buildInputs = [ hyperchroma which ];
  # } ''
  #   which hyperchroma

  #   touch $out
  # '');
}
