{ config, lib, pkgs, ... }:

let
  cfg = config.sys.desktop.chat.discord;
in
{
  options.sys.desktop.chat.discord = {
    enable = lib.mkEnableOption "Discord client";
    package = lib.mkPackageOption pkgs "discord" { };
    autostart = lib.mkEnableOption "Discord client on startup";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."discord/settings.json".source = (pkgs.formats.json { }).generate "discord-settings.json" {
      IS_MAXIMIZED = true;
      IS_MINIMIZED = false;
      SKIP_HOST_UPDATE = true;
    };

    systemd.user.services.discord-client = lib.mkIf cfg.autostart {
      Unit = {
        Description = "${cfg.package.name} Discord client";
        Requires = [
          "graphical-session-pre.target"
          "secrets-service.target"
        ];
        After = [ "secrets-service.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = lib.getExe cfg.package;
        Restart = "on-abort";
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
