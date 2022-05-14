# configuration.nix
#
# Edit this configuration file to define what should be installed on
#  your system.  Help is available in the configuration.nix(5) man page
#  and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }: {
  # Import other configuration files
  imports = [
    # Users
    ../../config/users/david/configuration.nix

    # Services
    ../../config/services/podman.nix
  ];

  sops = {
    gnupg = {
      home = "/var/lib/sops";
      sshKeyPaths = [ ];
    };

    secrets = {
      root-password = {
        sopsFile = ./secrets.yml;
        neededForUsers = true;
      };
    };
  };

  wsl = {
    enable = true;
    automountPath = "/mnt";
    defaultUser = "david";
    startMenuLaunchers = true;
  };

  users = {
    mutableUsers = false;
    users.root.passwordFile = config.sops.secrets.root-password.path;
  };

  networking = {
    hostName = "dh-framework";
    domain = "gh0st.network";
  };

  time.timeZone = "America/New_York";

  environment.systemPackages = with pkgs; [
    # FS tools
    cifs-utils
    lethe
    ntfs3g
    parted

    htop
    nixos-icons
    piper
    wally-cli
  ];

  systemd.tmpfiles.packages = with pkgs; [ openvpn podman-unwrapped man-db ];

  programs.gnupg.agent.enable = true;
}
