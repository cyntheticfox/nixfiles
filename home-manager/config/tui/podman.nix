{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    buildah
    cosign
    podman
    podman-compose
    skopeo
  ];

  xdg.configFile."containers/storage.conf".source = (pkgs.formats.toml { }).generate "storage.conf" {
    storage = {
      driver = "overlay";
      options.mount_program = "${pkgs.fuse-overlayfs}/bin/fuse-overlayfs";
    };
  };


  xdg.configFile."containers/registries.conf".source = (pkgs.formats.toml { }).generate "registries.conf" {
    registries.search.registries = [ "docker.io" ];
  };
}
