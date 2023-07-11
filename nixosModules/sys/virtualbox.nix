{ config, lib, ... }:
let
  cfg = config.sys.virtualbox;
in
{
  options.sys.virtualbox.enable = lib.mkEnableOption "VirtualBox";

  config = lib.mkIf cfg.enable {
    virtualisation.virtualbox.host = {
      inherit (cfg) enable;
      enableHardening = cfg.enable;
    };
  };
}
