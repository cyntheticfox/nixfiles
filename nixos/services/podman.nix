{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    buildah
    cosign
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

      dockerCompat = !config.virtualisation.docker.enable;
      dockerSocket.enable = !config.virtualisation.docker.enable;
    };
  };

  systemd.tmpfiles.packages = with pkgs; [ podman ];
}
