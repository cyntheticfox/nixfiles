# podman.nix
#
# Podman configuration

{ config, pkgs, lib, ... }: {
  environment.systemPackages = with pkgs; [
    buildah
    podman-compose
    shadow
    skopeo
  ];

  virtualisation = {
    containers = {
      enable = true;

      registries.search = [ "docker.io" "quay.io" "ghcr.io" ];
    };

    podman = {
      enable = true;

      dockerCompat = if config.virtualisation.docker.enable then false else true;
      dockerSocket.enable = if config.virtualisation.docker.enable then false else true;
      extraPackages = with pkgs; [ gvisor ];
    };
  };
}
