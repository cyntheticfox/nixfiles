builtins.zipAttrsWith (_: builtins.head) [
  (import ./trivial.nix)
  {
    mkHomeConfig = import ./mkHomeConfig.nix;
    mkNixosHomeConfig = import ./mkNixosHomeConfig.nix;
    mkNixosServer = import ./mkNixosServer.nix;
    mkNixosWorkstation = import ./mkNixosWorkstation.nix;
  }
]
