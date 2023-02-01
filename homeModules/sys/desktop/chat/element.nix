{ config, lib, pkgs, ... }:

let
  cfg = config.sys.desktop.chat.element;
in
{
  options.sys.desktop.chat.element = {
    enable = lib.mkEnableOption "Element, a Matrix client";

    package = lib.mkPackageOption pkgs "element-desktop" { };

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
