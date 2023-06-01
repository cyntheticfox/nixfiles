{ config, lib, pkgs, ... }:

let
  cfg = config.sys.desktop.web.edge;
in
{
  options.sys.desktop.web.edge = {
    enable = lib.mkEnableOption "Microsoft Edge";
    package = lib.mkPackageOption pkgs "microsoft-edge" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
