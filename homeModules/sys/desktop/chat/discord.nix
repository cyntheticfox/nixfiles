{ config, lib, pkgs, ... }:

let
  cfg = config.sys.desktop.chat.discord;
in
{
  options.sys.desktop.chat.discord = {
    enable = lib.mkEnableOption "Discord client";

    package = lib.mkPackageOption pkgs "discord" { };
    systemd-service = lib.mkEnableOption "discord Systemd user service" // { default = true; };
    autostart = lib.mkEnableOption "Discord client on startup";

    config = lib.mkOption {
      type = lib.types.attrs;

      default = {
        IS_MAXIMIZED = true;
        IS_MINIMIZED = false;
        SKIP_HOST_UPDATE = true;

        WINDOW_BOUNDS = {
          x = 0;
          y = 0;
          width = 1600;
          height = 1149;
        };
      };

      description = ''
        A series of <code>attrs</code> matching discord's <file>settings.json</file>.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."discord/settings.json".source = (pkgs.formats.json { }).generate "discord-settings.json" cfg.config;

    systemd.user.services.discord-client = lib.mkIf cfg.systemd-service {
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

        Environment = builtins.concatStringsSep " " [
          "BROWSER=${config.home.sessionVariables.BROWSER} "
          "NIXOS_OZONE_WL=1"
        ];
      };

      Install.WantedBy = lib.mkIf cfg.autostart [ "graphical-session.target" ];
    };
  };
}
