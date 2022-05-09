# configuration.nix
#
# Edit this configuration file to define what should be installed on
#  your system.  Help is available in the configuration.nix(5) man page
#  and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }: {
  # Import other configuration files
  imports = [
    ./hardware-configuration.nix

    # Users
    ../../config/users/david/configuration.nix

    # Desktop
    ../../config/desktops/sway.nix

    # Services
    ../../config/services/libvirtd.nix
    ../../config/services/cupsd.nix
    ../../config/services/podman.nix
    ../../config/services/clamav.nix
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

  users = {
    mutableUsers = false;
    users.root.passwordFile = config.sops.secrets.root-password.path;
  };

  networking = {
    hostName = "dh-laptop2";
    domain = "gh0st.network";

    interfaces = {
      enp1s0.useDHCP = true;
      wlp0s20f3.useDHCP = true;
    };

    # TODO: Add Keyfile configurations
    networkmanager = {
      enable = true;

      unmanaged = [ ];

      insertNameservers = [
        "2620:fe::fe"
        "2620:fe::9"
        "9.9.9.9"
        "149.112.112.112"
      ];
      wifi.powersave = true;
    } // (
      if
        config.system.stateVersion == "21.11"
      then
        {
          packages = with pkgs; [ networkmanager-openvpn ];
        }
      else
        {
          plugins = with pkgs; [ networkmanager-openvpn ];
        }
    );

    enableIPv6 = true;

    firewall = {
      enable = true;
      allowPing = true;
    };

    wireless.scanOnLowSignal = false;
  };

  time.timeZone = "America/New_York";

  environment.systemPackages = with pkgs; [
    # FS tools
    cifs-utils
    lethe
    ntfs3g
    parted
    udiskie

    bluez-tools
    htop
    nixos-icons
    piper
    wally-cli
  ];

  systemd.tmpfiles.packages = with pkgs; [ openvpn podman-unwrapped man-db ];

  programs.gnupg.agent.enable = true;

  # Enable Steam for gaming
  programs.steam.enable = true;

  # Sound config
  security.rtkit.enable = true;
  sound.enable = true;
  services.pipewire = {
    enable = true;

    alsa.enable = true;
    jack.enable = true;
    pulse.enable = true;
  } // (
    if
      config.system.stateVersion == "22.05"
    then
      {
        audio.enable = true;
        wireplumber.enable = true;
      }
    else
      { }
  );
}
