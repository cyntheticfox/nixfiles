{ pkgs
, outputs
, system
, ...
}:

with pkgs;

let
  testSystem = configuration: (outputs.lib.defFlakeSystem {
    modules = [
      { nixpkgs.config.allowUnfree = false; }
      configuration
    ];
  }).config.system.build.toplevel;
in
lib.optionalAttrs (system == "x86_64-linux") {
  dh-laptop2-config = testSystem ../nixos/hosts/dh-laptop2/configuration.nix;
}
