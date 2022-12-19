args:

let
  hosts-tests = import ./hosts.nix args;
  hm-tests = import ./homeModules args;
in

{ } // hosts-tests // hm-tests
