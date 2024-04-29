{ config, lib, pkgs, ... }:

let
  cfg = config.sys.cloud;
in
{
  options.sys.cloud = {
    aws = {
      enable = lib.mkEnableOption "Amazon Web Services";
      package = lib.mkPackageOption pkgs "awscli2" { };

      profiles = lib.mkOption {
        type = with lib.types; attrsOf (attrsOf str);
        default = { };
        description = ''
          AWS Profiles to declare in your <filename>~/.aws/config</filename>.
        '';
      };
    };

    azure = {
      enable = lib.mkEnableOption "Microsoft Azure";
      package = lib.mkPackageOption pkgs "azure-cli" { };
    };

    gcp = {
      enable = lib.mkEnableOption "Google Cloud Platform";
      package = lib.mkPackageOption pkgs "google-cloud-sdk" { };
    };

    openshift = {
      enable = lib.mkEnableOption "OpenShift tools";
      ocm.package = lib.mkPackageOption pkgs "ocm" { };
      odo.package = lib.mkPackageOption pkgs "odo" { };
    };

    opentofu = {
      enable = lib.mkEnableOption "OpenTofu";
      package = lib.mkPackageOption pkgs "opentofu" { };
    };

    backup = {
      b2 = {
        enable = lib.mkEnableOption "Backblaze B2";
        package = lib.mkPackageOption pkgs "backblaze-b2" { };
      };

      rclone = {
        enable = lib.mkEnableOption "rclone";
        package = lib.mkPackageOption pkgs "rclone" { };
      };
    };

    flyctl = {
      enable = lib.mkEnableOption "Fly.io CLI";
      package = lib.mkPackageOption pkgs "flyctl" { };
    };

    kubernetes = {
      kubectl = {
        enable = lib.mkEnableOption "Kubernetes CLI";
        package = lib.mkPackageOption "kubectl" { };
      };

      helm = {
        enable = lib.mkEnableOption "Kubernetes Helm package manager";
        package = lib.mkPackageOption "kubernetes-helm" { };
      };

      minikube = {
        enable = lib.mkEnableOption "Local Kubernetes test cluster";
        package = lib.mkPackageOption "minikube" { };
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.aws.enable (lib.mkMerge [
      {
        home.packages = with pkgs; [
          cfg.aws.package
          nodePackages.aws-cdk
          nodePackages.serverless
        ];
      }

      (lib.mkIf (cfg.aws.profiles != { }) {
        home.file.".aws/config".text = builtins.concatStringsSep "\n" (lib.mapAttrsToList
          (name: values: ''
            [${name}]
            ${builtins.concatStringsSep "\n" (lib.mapAttrsToList (n: v: "${n}=${v}") values)}
          '')
          cfg.aws.profiles);
      })
    ]))

    (lib.mkIf cfg.azure.enable {
      home.packages = with pkgs; [
        cfg.azure.package
        powershell
      ];

      # TODO: Make own module
      home.file.".azure/config".text = ''
        [core]
        output=table
        collect_telemetry=false

        [logging]
        enable_log_file=true
        log_dir="${config.xdg.dataHome}/azure/logs"

        [defaults]
        location=eastus

        [cloud]
        name=AzureCloud
      '';
    })

    (lib.mkIf cfg.gcp.enable {
      home.packages = [ cfg.gcp.package ];
    })

    (lib.mkIf cfg.opentofu.enable {
      home.packages = [ cfg.opentofu.package ];
    })

    (lib.mkIf cfg.backup.b2.enable {
      home.packages = [ cfg.backup.b2.package ];
    })

    (lib.mkIf cfg.backup.rclone.enable {
      home.packages = [ cfg.backup.rclone.package ];
    })

    (lib.mkIf cfg.flyctl.enable {
      home.packages = [ cfg.flyctl.package ];
    })

    (lib.mkIf cfg.kubernetes.kubectl.enable {
      home.packages = [ cfg.kubernetes.kubectl.enable ];
    })

    (lib.mkIf cfg.kubernetes.helm.enable {
      home.packages = [ cfg.kubernetes.helm.enable ];
    })

    (lib.mkIf cfg.kubernetes.minikube.enable {
      home.packages = [ cfg.kubernetes.minikube.enable ];
    })

    (lib.mkIf cfg.openshift.enable {
      home.packages = [
        cfg.openshift.odo.package
        cfg.openshift.ocm.package
      ];
    })
  ];
}
