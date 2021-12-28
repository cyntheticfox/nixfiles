# podman.nix
#
# Podman configuration

{ config, pkgs, lib, ... }: {
  environment.systemPackages = with pkgs; [
    shadow
    buildah
  ];

  virtualisation = {
    containers = {
      enable = true;
      registries.search = [ "docker.io" "quay.io" ];
    };

    podman = {
      enable = true;
    };
  };
}
