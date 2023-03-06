{ config, lib, pkgs, ... }:

let
  cfg = config.sys.desktop.chat.msteams;
in
{
  options.sys.desktop.chat.msteams = {
    enable = lib.mkEnableOption "Microsoft teams";
    package = lib.mkPackageOption pkgs "teams" { };
    autostart = lib.mkEnableOption "Microsoft Teams on startup";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.mimeApps.defaultApplications."x-scheme-handler/msteams" = "${cfg.package.name}.desktop";

    systemd.user.services.msteams-client = lib.mkIf cfg.autostart {
      Unit = {
        Description = "${cfg.package.name} Microsoft Teams client";
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
      } // lib.optionalAttrs (cfg.package.pname == "teams-for-linux" && (config.desktop.sway.enable or false)) {
        # Enable Electron on wayland
        Environment = "NIXOS_OZONE_WL=1";
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };

    # For whatever reason, teams likes to overwrite the mimetypes, even if it's
    #   fine. So, add a step to activation to remove the file if it's not a link.
    #
    home.activation.remove-mimeapps = lib.mkIf (cfg.package.pname == "teams")
      (
        let
          filename = "${config.xdg.configHome}/mimeapps.list";
        in
        lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
          if [ -e ${filename} ]; then
            if [ ! -L ${filename} ]; then
              $DRY_RUN_CMD rm $VERBOSE_ARG ${filename}
            fi
          fi
        ''
      );
  };
}
