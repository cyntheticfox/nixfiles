{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    # CLIs
    awscli2
    azure-cli
    backblaze-b2
    flyctl
    google-cloud-sdk
    linode-cli
    nixpkgs-unstable.nodePackages.serverless

    # Terraform/HashiCorp
    nixpkgs-unstable.nodePackages.cdktf-cli
    infracost
    packer
    terracognita
    terraform
    terrascan
    tflint
    tfsec

    # Kubernetes
    chart-testing
    datree
    istioctl
    kube-hunter
    kube-linter
    kubectl
    kubernetes-helm
    kustomize
    minikube
    rancher

    # Cloud-Native clis
    kn
    open-policy-agent
    tektoncd-cli

    # OpenShift
    ocm
    odo

    # Cost tools
    cloud-custodian
  ];
}
