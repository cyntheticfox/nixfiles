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

      wireless = {
        sopsFile = ./secrets.yml;
      };

      wired = {
        sopsFile = ./secrets.yml;
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

    wireless.scanOnLowSignal = false;
    useNetworkd = true;
  };

  networking.supplicant.wlp0s20f3 = {
    driver = "nl80211";
    extraConf = ''
      p2p_disabled=1
    '';
    configFile.path = config.sops.secrets.wireless.path;
    userControlled.enable = true;
  };
  networking.interfaces.wlp0s20f3.useDHCP = true;
  systemd.network.networks."40-wlp0s20f3" = {
    dhcpV4Config = {
      ClientIdentifier = "mac";
      RouteMetric = 600;
    };
    dhcpV6Config.RouteMetric = 600;
  };

  networking.supplicant.enp1s0 = {
    driver = "wired";
    extraConf = ''
      ap_scan=0
    '';
    configFile.path = config.sops.secrets.wired.path;
    userControlled.enable = true;
  };
  networking.interfaces.enp1s0.useDHCP = true;
  systemd.network.networks."40-enp1s0" = {
    dhcpV4Config = {
      ClientIdentifier = "mac";
      RouteMetric = 100;
    };
    dhcpV6Config.RouteMetric = 100;
    linkConfig.RequiredForOnline = "no";
  };

  # networking.supplicant.enp0s20f0u4u4 = {
  #   driver = "wired";
  #   extraConf = ''
  #     ap_scan=0
  #   '';
  #   configFile.path = config.sops.secrets.wired.path;
  #   userControlled.enable = true;
  # };
  # networking.interfaces.enp0s20f0u4u4.useDHCP = true;
  # systemd.network.networks."40-enp0s20f0u4u4" = {
  #   dhcpV4Config = {
  #     ClientIdentifier = "mac";
  #     RouteMetric = 100;
  #   };
  #   dhcpV6Config.RouteMetric = 100;
  #   linkConfig.RequiredForOnline = "no";
  # };

  systemd.network.networks."80-wl" = {
    name = "wl*";
    DHCP = "yes";

    dhcpV4Config = {
      ClientIdentifier = "mac";
      RouteMetric = 700;
    };
    dhcpV6Config.RouteMetric = 700;
    linkConfig.RequiredForOnline = "no";
    networkConfig.IPv6PrivacyExtensions = "kernel";
  };

  systemd.network.networks."80-en" = {
    name = "en*";
    DHCP = "yes";

    dhcpV4Config = {
      ClientIdentifier = "mac";
      RouteMetric = 200;
    };
    dhcpV6Config.RouteMetric = 200;
    linkConfig.RequiredForOnline = "no";
    networkConfig.IPv6PrivacyExtensions = "kernel";
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
