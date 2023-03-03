{ config, lib, pkgs, ... }:

let
  cfg = config.sys.desktop.chat.matrix;
in
{
  options.sys.desktop.chat.matrix = {
    enable = lib.mkEnableOption "matrix client";

    package = lib.mkPackageOption pkgs "nheko" { };

    autostart = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  # TODO: Move autostart config from hm/sys/desktop/sway
  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
