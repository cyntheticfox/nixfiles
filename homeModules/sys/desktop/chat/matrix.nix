{ config, lib, pkgs, ... }:

let
  cfg = config.sys.desktop.chat.matrix;
in
{
  options.sys.desktop.chat.matrix = {
    enable = lib.mkEnableOption "Matrix client";
    package = lib.mkPackageOption pkgs "nheko" { };
    autostart = lib.mkEnableOption "Matrix client on startup";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    systemd.user.services.matrix-client = lib.mkIf cfg.autostart {
      Unit = {
        Description = "${cfg.package.name} Matrix client";
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
