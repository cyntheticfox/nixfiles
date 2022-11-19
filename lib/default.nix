{
  defFlakeSystem = import ./defFlakeSystem.nix;
  defFlakeServer = import ./defFlakeServer.nix;
  defFlakeWorkstation = import ./defFlakeWorkstation.nix;
  hmConfig = import ./hmConfig.nix;
  personalNixosHMConfig = import ./personalNixosHMConfig.nix;
}
