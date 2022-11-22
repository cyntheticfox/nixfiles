{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.sys.cloud;
in
{
  options.sys.cloud = {
    enable = mkEnableOption "Provide cloud CLI packages and maybe config";

    manageAwsConfig = mkEnableOption "Manage AWS configuration if so desired";
    manageAzureConfig = mkEnableOption "Manage MS Azure configuration if so desired";
    manageGcpConfig = mkEnableOption "Manage GCP configuration if so desired";

    extraCloudPackages = mkOption {
      type = with types; listOf package;
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

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = with pkgs; [
        nodePackages.cdktf-cli
        packer
        kubectl
        kubernetes-helm
        terraform
      ] ++ cfg.extraCloudPackages;
    }
    (mkIf cfg.manageAwsConfig {
      home.packages = with pkgs; [
        awscli2
        # nodePackages.aws-cdk # TODO: fix when npmBuild is fixed
        nodePackages.serverless
      ];

      # TODO: Make own module
      home.file.".aws/config".text = ''
        [default]
        region = us-east-1
        output = table
        cli_pager = ${config.home.sessionVariables.PAGER or "less"}
        retry_mode = standard
      '';
    })
    (mkIf cfg.manageAzureConfig {
      home.packages = with pkgs; [
        azure-cli
        powershell
      ];

      # TODO: Make own module
      home.file.".azure/config".text = ''
        [core]
        output=table
        collect_telemetry=false

        [logging]
        enable_log_file=true
        log_dir="${(config.xdg.dataHome + "/azure/logs")}

        [defaults]
        location=eastus

        [cloud]
        name=AzureCloud
      '';
    })
    (mkIf cfg.manageGcpConfig {
      home.packages = with pkgs; [ google-cloud-sdk ];
    })
  ]);
}
