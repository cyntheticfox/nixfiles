{ config, pkgs, ... }: {
  # Import other configuration files
  imports = [
    ./hardware-configuration.nix

    # Users
    ../../nixos/config/users/david/configuration.nix

    # Desktop
    ../../nixos/config/desktops/sway.nix

    # Services
    # ../../nixos/config/services/clamav.nix
    ../../nixos/config/services/cupsd.nix
    ../../nixos/config/services/libvirtd.nix
    ../../nixos/config/services/restic.nix
  ];

  sops = {
    gnupg = {
      home = "/state/var/lib/sops";
      sshKeyPaths = [ ];
    };

    secrets = {
      root-password = {
        sopsFile = ./secrets.yml;
        neededForUsers = true;
      };

      wireless = {
        sopsFile = ./secrets.yml;
        restartUnits = [ "supplicant-wlp0s20f3" ];
      };

      restic-password = {
        sopsFile = ./secrets.yml;
      };

      restic-environment = {
        sopsFile = ./secrets.yml;
      };
    };
  };

  environment.persistence."/state" = {
    hideMounts = true;
    directories = [
      "/var/lib/sops"
    ];

    files = [
      "/etc/machine-id"
    ];
  };

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/db/sudo"
      "/var/lib/bluetooth"
      {
        directory = "/var/lib/clamav";
        user = "clamav";
        group = "clamav";
      }
      "/var/lib/containers"
      {
        directory = "/var/lib/docker";
        mode = "u=rwx,g=x,o=";
      }
      "/var/lib/libvirt"
      "/var/lib/minikube"
      "/var/lib/systemd/coredump"
      "/var/log"
      "/var/tmp"
    ];
  };

  users = {
    mutableUsers = false;
    users.root.passwordFile = config.sops.secrets.root-password.path;
  };

  networking = {
    hostName = "dh-framework";
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
    restic
    udiskie

    bluez-tools
    minikube
    nixos-icons
    piper
    wally-cli
  ];

  services.restic.backups."${config.networking.hostName}" = {
    passwordFile = config.sops.secrets.restic-password.path;
    environmentFile = config.sops.secrets.restic-environment.path;
  };

  systemd.services."restic-backups-${config.networking.hostName}".serviceConfig.ExecCondition = "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --interface=enp0s13f0u4u4:routable --timeout=5";

  systemd.tmpfiles.packages = with pkgs; [ openvpn man-db ];

  programs.gnupg.agent.enable = true;

  programs.steam.enable = true;

  security.rtkit.enable = true;

  sound.enable = true;
  services.pipewire = {
    enable = true;

    alsa.enable = true;
    jack.enable = true;
    pulse.enable = true;
    audio.enable = true;
    wireplumber.enable = true;
  };

  systemd.user.services.pipewire-pulse.path = [ pkgs.pulseaudio ];
}
