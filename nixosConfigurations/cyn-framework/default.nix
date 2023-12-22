{ config, pkgs, ... }: {
  # Import other configuration files
  imports = [
    ./hardware-configuration.nix

    # Users
    ../../nixosUserConfigurations/cynthia/configuration.nix
  ];

  environment = {
    persistence = {
      "/state" = {
        hideMounts = true;

        directories = [
          "/var/lib/sops"
        ];

        files = [
          "/etc/machine-id"
        ];
      };

      "/persist" = {
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
          "/var/lib/fprint"
          "/var/lib/fwupd"
          "/var/lib/libvirt"
          "/var/lib/minikube"
          "/var/lib/systemd/coredump"
          "/var/log"
          "/var/tmp"
        ];
      };
    };

    systemPackages = with pkgs; [
      # FS tools
      cifs-utils
      lethe
      ntfs3g
      parted
      restic

      bluez-tools
      nixos-icons
      piper
      wally-cli
    ];
  };

  users = {
    mutableUsers = false;
    users.root.hashedPasswordFile = config.sops.secrets.root-password.path;
  };

  networking = {
    networkmanager = {
      enable = true;

      insertNameservers = [ "9.9.9.9" "149.112.112.112" ];
      unmanaged = [ "wlp0s20f3" ];
    };

    interfaces.wlp0s20f3.useDHCP = true;

    supplicant.wlp0s20f3 = {
      driver = "nl80211";
      extraConf = "p2p_disabled=1";
      configFile.path = config.sops.secrets.wireless.path;
      userControlled.enable = true;
    };

    useNetworkd = true;
    wireless.scanOnLowSignal = false;
  };

  programs = {
    gnupg.agent.enable = true;

    steam.enable = true;
  };

  security.rtkit.enable = true;

  services = {
    dbus.implementation = "broker";

    pipewire = {
      enable = true;

      alsa.enable = true;
      jack.enable = true;
      pulse.enable = true;
      audio.enable = true;
      wireplumber.enable = true;
    };

    udisks2.enable = true;
    upower.enable = true;
  };

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

  sound.enable = true;

  sys = {
    backup = {
      enable = true;
      paths = [ "/state" ];

      passwordFile = config.sops.secrets.restic-password.path;
      environmentFile = config.sops.secrets.restic-environment.path;
    };

    core.nix-experimental-features = [
      "nix-command"
      "flakes"
      "ca-derivations"
    ];

    desktop.sway.enable = true;
    libvirtd.enable = true;
    print.enable = true;
    podman.enable = true;
  };

  systemd = {
    network.networks = {
      "40-wlp0s20f3" = {
        dhcpV4Config = {
          ClientIdentifier = "mac";
          RouteMetric = 650;
        };

        dhcpV6Config.RouteMetric = 600;
      };

      "80-wl" = {
        name = "wl*";
        DHCP = "yes";

        dhcpV4Config = {
          ClientIdentifier = "mac";
          RouteMetric = 750;
        };

        dhcpV6Config.RouteMetric = 700;
        linkConfig.RequiredForOnline = "no";
        networkConfig.IPv6PrivacyExtensions = "kernel";
      };

      "80-en" = {
        name = "en*";
        DHCP = "yes";

        dhcpV4Config = {
          ClientIdentifier = "mac";
          RouteMetric = 250;
        };

        dhcpV6Config.RouteMetric = 200;
        linkConfig.RequiredForOnline = "no";
        networkConfig.IPv6PrivacyExtensions = "kernel";
      };
    };

    services."restic-backups-${config.networking.hostName}".serviceConfig.ExecCondition = "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --interface=enp0s13f0u4u4:routable --timeout=5";

    user.services.pipewire-pulse.path = [ pkgs.pulseaudio ];
    tmpfiles.packages = with pkgs; [ openvpn man-db ];
  };

  time.timeZone = "America/New_York";
}
