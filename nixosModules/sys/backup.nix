{ config, lib, ... }:
let
  cfg = config.sys.backup;
in
{
  options.sys.backup = {
    enable = lib.mkEnableOption "system-wide backups";

    jobName = lib.mkOption {
      type = lib.types.str;
      default = "restic-backups-${config.networking.hostName}";
      description = ''
        Name of the systemd job to create.
      '';
    };

    paths = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ "/" ];
      description = ''
        The list of (absolute) paths to back up.
      '';
    };

    passwordFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        Path to the file containing sensitive password files.
      '';
    };

    environmentFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        Path to the file containing sensitive environment files.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.restic.backups.${config.networking.hostName} = {
      inherit (cfg) paths passwordFile environmentFile;

      initialize = true;
      repository = "b2:${builtins.replaceStrings ["."] ["-"] config.networking.fqdn}-backup";

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
        "--keep-yearly 2"
      ];

      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };

    systemd.services.${cfg.jobName} = {
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
    };
  };
}
