{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    # CLIs
    awscli2
    azure-cli
    backblaze-b2
    linode-cli
    pulumi-bin
    rancher

    # Provisioning Tools
    ansible
    nixpkgs-unstable.nodePackages.cdktf-cli
    helm
    istioctl
    kubectl
    ocm
    odo
    packer
    terraform

    # Generators
    terracognita

    # Locking tools
    terragrunt

    # Checking tools
    chart-testing
    datree
    kube-hunter
    kube-linter
    terrascan
    tflint
    tfsec

    # Cost tools
    cloud-custodian
    infracost
  ];
}
