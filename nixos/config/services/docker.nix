{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  virtualisation = {
    containers = {
      enable = true;

      registries.search = [
        "docker.io"
        "quay.io"
        "ghcr.io"
      ];
    };

    docker.enable = true;
  };
}
