{ config, lib, pkgs, ... }:

let
  cfg = config.sys.podman;
in
{
  options.sys.podman = {
    enable = lib.mkEnableOption "podman";

    package = lib.mkPackageOption pkgs "podman" { };
    composePackage = lib.mkPackageOption pkgs "podman-compose" { };

    registries = lib.mkOption {
      type = with lib.types; listOf str;

      default = [
        "docker.io"
        "quay.io"
        "ghcr.io"
      ];

      description = ''
        Registries to search when using podman search.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.composePackage ];

    virtualisation = {
      containers = {
        inherit (cfg) enable;

        registries.search = cfg.registries;
      };

      podman = {
        inherit (cfg) enable package;
      };
    };
  };
}
