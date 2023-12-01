{ config, lib, pkgs, ... }:

let
  cfg = config.sys.cloud;
in
{
  options.sys.cloud = {
    enable = lib.mkEnableOption "Provide cloud CLI packages and maybe config";

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

    extraCloudPackages = lib.mkOption {
      type = with lib.types; listOf package;

      default = with pkgs; [
        backblaze-b2
        cloud-custodian
        flyctl
        linode-cli

        # Terraform/Hashicorp
        infracost
        terrascan
        tflint
        tfsec

        # Kubernetes
        chart-testing
        datree
        kube-hunter
        kube-linter
        kustomize
        minikube
        rancher

        # Cloud-Native tools
        istioctl
        kn
        open-policy-agent
        tektoncd-cli

        # OpenShift
        ocm
        odo
      ];
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = with pkgs; [
        nodePackages.cdktf-cli
        packer
        kubectl
        kubernetes-helm
        opentofu # Open Source Terraform
      ] ++ cfg.extraCloudPackages;
    }

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
  ]);
}
