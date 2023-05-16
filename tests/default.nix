args:

let
  hosts-tests = import ./hosts.nix args;
  hm-tests = import ./homeModules args;
  homeConfig-tests = import ./homeConfigurations.nix args;
in

{ } // hosts-tests // hm-tests // homeConfig-tests
