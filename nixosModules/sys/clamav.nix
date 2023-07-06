{ config, lib, pkgs, ... }:
let
  cfg = config.sys.clamav;
in
{
  options.sys.clamav = {
    enable = lib.mkEnableOption "ClamAV Virus Scan";
    package = lib.mkPackageOption pkgs "clamav" { };
  };

  config = lib.mkIf cfg.enable {
    services.clamav = {
      daemon = {
        enable = true;

        settings = {
          DetectPUA = true;
          LogFile = "/var/log/clamd.log";
          LogTime = true;

          VirusEvent = lib.escapeShellArgs [
            "${pkgs.libnotify}/bin/notify-send"
            "--"
            "ClamAV Virus Scan"
            "Found virus: %v"
          ];
        };
      };

      updater = {
        enable = true;
        frequency = 24;
        interval = "hourly";
      };
    };

    systemd =
      let
        description = "Run ClamAV Virus Scan";
        documentation = [ "man(1):clamscan" ];
      in
      {
        services.clamav-scan = {
          inherit description documentation;

          script = "${cfg.package}/bin/clamscan -i -r -- /home";
          serviceConfig.Type = "oneshot";
        };

        timers.clamav-scan = {
          inherit description documentation;

          wantedBy = [ "timers.target" ];

          timerConfig = {
            OnCalendar = "weekly";
            Persistent = true;
          };
        };
      };
  };
}
