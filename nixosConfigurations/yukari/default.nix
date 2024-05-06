{
  config,
  lib,
  pkgs,
  ...
}:
{
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

        directories = [ "/var/lib/sops" ];

        files = [ "/etc/machine-id" ];
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
      rustic-rs

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
    firewall.enable = true;

    networkmanager = {
      enable = true;

      insertNameservers = [
        "9.9.9.9"
        "149.112.112.112"
      ];
      unmanaged = [ "wlp0s20f3" ];
    };

    nftables = {
      enable = true;
      ruleset = '''';
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
    defaultSopsFile = ./secrets.yml;

    gnupg = {
      home = "/state/var/lib/sops";
      sshKeyPaths = [ ];
    };

    secrets = {
      root-password.neededForUsers = true;
      rustic-app-key = { };
      rustic-app-key-id = { };
      rustic-bucket-id = { };
      rustic-environment = { };
      rustic-password = { };
      wireless.restartUnits = [ "supplicant-wlp0s20f3" ];
    };
  };

  sound.enable = true;

  sys = {
    rustic-b2 = {
      enable = true;
      package = pkgs.nixpkgs-unstable.rustic-rs;
      sources = [ { source = "/state"; } ];
      passwordFile = config.sops.secrets.rustic-password.path;
      environmentFile = config.sops.secrets.rustic-environment.path;
      configOverrideSource = config.sops.templates."rustic.toml".path;
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

  sops.templates."rustic.toml".content = ''
    [repository]
    repository = "opendal:b2"
    password-file = "${config.sys.rustic-b2.passwordFile}"

    [repository.options]
    bucket = "${config.sys.rustic-b2.bucket}"
    bucket_id = "${config.sops.placeholder.rustic-bucket-id}"
    application_key_id = "${config.sops.placeholder.rustic-app-key-id}"
    application_key = "${config.sops.placeholder.rustic-app-key}"

    [[backup.sources]]
    source = "/state"

    [forget]
    keep-daily = 7
    keep-weekly = 5
    keep-monthly = 12
    keep-yearly = 2
    prune = true
  '';

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

    services."rustic-backups-${config.networking.hostName}".serviceConfig =
      let
        interface = "wlp0s20f3";
        ssid = "Spectre";
      in
      {
        ExecCondition = [
          "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --interface=${interface}:routable --timeout=5"
          "+${lib.getExe pkgs.bash} -c '${pkgs.wpa_supplicant}/bin/wpa_cli -i ${interface} status | ${lib.getExe pkgs.gnugrep} ^ssid=${ssid}'"
        ];
      };

    user.services.pipewire-pulse.path = [ pkgs.pulseaudio ];
    tmpfiles.packages = with pkgs; [
      openvpn
      man-db
    ];
  };

  time.timeZone = "America/New_York";
}
