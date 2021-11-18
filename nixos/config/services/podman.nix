# podman.nix
#
# Podman configuration

{ config, pkgs, lib, ... }: {
  environment.systemPackages = with pkgs; [
    shadow
    buildah
  ];

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };

    oci-containers = {
      backend = "podman";
    };
  };

  environment.etc."containers/registry.conf" = {
    mode = "0644";
    text = ''
      [registries.search]
      registries = ['docker.io', 'quay.io']
    '';
  };
}
