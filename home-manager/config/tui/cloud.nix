{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    # CLIs
    awscli2
    azure-cli
    linode-cli

    # Provisioning Tools
    ansible
    kubectl
    terraform
  ];
}
