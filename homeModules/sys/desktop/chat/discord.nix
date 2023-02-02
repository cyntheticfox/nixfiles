{ config, lib, pkgs, ... }:

let
  cfg = config.sys.desktop.chat.discord;
in
{
  options.sys.desktop.chat.discord = {
    enable = lib.mkEnableOption "Discord";

    package = lib.mkPackageOption pkgs "discord" { };

    autostart = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."discord/settings.json".source = (pkgs.formats.json { }).generate "discord-settings.json" {
      IS_MAXIMIZED = true;
      IS_MINIMIZED = false;
      SKIP_HOST_UPDATE = true;
    };
  };
}
