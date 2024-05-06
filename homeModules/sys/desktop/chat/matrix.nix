{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.sys.desktop.chat.matrix;
in
{
  options.sys.desktop.chat.matrix = {
    enable = lib.mkEnableOption "Matrix client";
    package = lib.mkPackageOption pkgs "nheko" { };
    systemd-service = lib.mkEnableOption "Matrix client systemd service" // {
      default = true;
    };
    autostart = lib.mkEnableOption "Matrix client on startup";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    systemd.user.services.matrix-client = lib.mkIf cfg.systemd-service {
      Unit = {
        Description = "${cfg.package.name} Matrix client";

        Requires = [
          "graphical-session-pre.target"
          "network-online.target"
        ] ++ lib.optional (cfg.package.name == "nheko") "secrets-service.target";

        After = lib.mkIf (cfg.package.name == "nheko") "secrets-service.target";
      };

      Service = {
        Type = "simple";
        ExecStart = lib.getExe cfg.package;
        Restart = "on-abort";
        Environment = "BROWSER=${config.home.sessionVariables.BROWSER}";
      };

      Install.WantedBy = lib.mkIf cfg.autostart [ "graphical-session.target" ];
    };
  };
}
