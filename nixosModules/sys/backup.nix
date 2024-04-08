{ config, lib, pkgs, utils, ... }:
let
  cfg = config.sys.rustic-b2;
in
{
  options.sys.rustic-b2 = {
    enable = lib.mkEnableOption "system-wide backups";
    package = lib.mkPackageOption pkgs "rustic-rs" { };

    repository = lib.mkOption {
      type = lib.types.str;
      description = ''
        The repository in which to store the backup.
      '';
    };

    jobName = lib.mkOption {
      type = lib.types.str;
      default = "rustic-backups-${config.networking.hostName}";
      description = ''
        Name of the systemd job to create.
      '';
    };

    sources = lib.mkOption {
      type = with lib.types; listOf attrs;
      default = [{ source = "/"; }];
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

    bucket = lib.mkOption {
      type = lib.types.str;
      default = "${builtins.replaceStrings ["."] ["-"] config.networking.fqdn}-backup";
    };

    # bucketId = lib.mkOption {
    #   type = lib.types.str;
    # };

    exclude = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "root";
    };

    timerConfig = lib.mkOption {
      type = with lib.types; nullOr (attrsOf utils.systemdUtils.unitOptions.unitOption);

      default = {
        OnCalendar = "daily";
        AccuracySec = "1m";
        RandomizedDelaySec = "1h";
        Persistent = true;
      };
    };

    initialize = lib.mkOption {
      type = lib.types.bool;
      default = false;

      description = lib.mdDoc ''
        Create the repository if it doesn't exist.
      '';
    };

    configOverrideSource = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."rustic/rustic.toml".source =
      if
        cfg.configOverrideSource != null
      then
        cfg.configOverrideSource
      else
        (pkgs.formats.toml { }).generate "rustic.toml" {
          repository = {
            repository = "opendal:b2";
            password-file = cfg.passwordFile;

            options = {
              inherit (cfg) bucket;

              # bucket_id = cfg.bucketId;
              bucket_id = " ";
              application_key_id = " ";
              application_key = " ";
            };
          };

          forget = {
            keep-daily = 7;
            keep-weekly = 5;
            keep-monthly = 12;
            keep-yearly = 2;
            prune = true;
          };

          backup.sources = cfg.sources;
        };

    systemd.services.${cfg.jobName} =
      let
        rusticBin = lib.getExe cfg.package;
      in
      {
        restartIfChanged = false;
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        serviceConfig = {
          Type = "oneshot";

          ExecStart = [
            "${rusticBin} backup"
            "${rusticBin} prune"
          ];

          User = cfg.user;
          RuntimeDirectory = cfg.jobName;
          CacheDirectory = cfg.jobName;
          CacheDirectoryMode = "0700";
          PrivateTmp = true;
          EnvironmentFile = cfg.environmentFile;
          Nice = 19;
          KillSignal = "SIGINT";
          IOSchedulingClass = "idle";
        };

        preStart = ''
          ${(lib.optionalString cfg.initialize "${rusticBin} snapshots || ${rusticBin} init")}
        '';
      };

    systemd.timers.${cfg.jobName} = {
      inherit (cfg) timerConfig;

      wantedBy = [ "timers.target" ];
    };

    environment.systemPackages = [ cfg.package ];
  };
}
