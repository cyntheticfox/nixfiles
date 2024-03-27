{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.sys.podman;
in
{
  options.sys.podman.enable = mkEnableOption "Configure podman for rootless container use";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      buildah
      cosign
      podman
      podman-compose
      skopeo
    ];

    xdg.configFile = {
      "containers/containers.conf".source = (pkgs.formats.toml { }).generate "containers.conf" {
        containers = {
          default_sysctls = [
            "net.ipv4.conf.all.arp_filter=1"
            "net.ipv4.conf.all.rp_filter=1"
          ];
          init = true;
          init_path = "${pkgs.catatonit}/bin/catatonit";
          ipcns = "private"; # Why is "sharable" the default???
          seccomp_profile = config.xdg.configFile."containers/seccomp.json".source.outPath;
          tz = "local";
          # userns = "private";
        };
        network.cni_plugin_dirs = [ "${pkgs.cni-plugins}/bin" ];
      };

      "containers/storage.conf".source = (pkgs.formats.toml { }).generate "storage.conf" {
        storage = {
          driver = "overlay";
          options.mount_program = "${pkgs.fuse-overlayfs}/bin/fuse-overlayfs";
        };
      };

      "containers/seccomp.json".source = (pkgs.formats.json { }).generate "seccomp.json" {
        defaultAction = "SCMP_ACT_ALLOW";
        architectures = [
          "SCMP_ARCH_X86_64"
          "SCMP_ARCH_X86"
        ];
        syscalls = [ ];
      };

      "containers/registries.conf".source = (pkgs.formats.toml { }).generate "registries.conf" {
        registries.search.registries = [ "docker.io" ];
      };

      "containers/policy.json".source = (pkgs.formats.json { }).generate "policy.json" {
        default = [{ type = "reject"; }];
        transports = {
          dir."" = [{ type = "insecureAcceptAnything"; }];
          oci."" = [{ type = "insecureAcceptAnything"; }];
          tarball."" = [{ type = "insecureAcceptAnything"; }];
          docker-daemon."" = [{ type = "insecureAcceptAnything"; }];
          docker-archive."" = [{ type = "insecureAcceptAnything"; }];
          oci-archive."" = [{ type = "insecureAcceptAnything"; }];
          docker = {
            "" = [{ type = "reject"; }];
            "docker.io/library" = [{ type = "insecureAcceptAnything"; }];
            "docker.io/nixos" = [{ type = "insecureAcceptAnything"; }];
            "docker.io/fireflyiii" = [{ type = "insecureAcceptAnything"; }];
          };
        };
      };
    };
  };
}
