{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../config/services/podman.nix
    ../../config/services/sshd.nix
  ];

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "vga=current" ];
  };

  networking = {
    hostName = "ashley";
    enableIPv6 = true;
    useDHCP = false;
    interfaces.enp2s0.useDHCP = true;
    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [
        139
        445
        8096
        8866
        8920
      ];
      allowedUDPPorts = [
        16891
      ];
    };
  };

  time.timeZone = "America/New_York";

  users.mutableUsers = false;
  users.users.root = {
    hashedPassword = "$6$paNcgqe0JBE3W$u1CwTahnW5wMlfxkzTApWJdYyncnDWa6XLhr0GucM2DYPeQw/Tyv2mo8HtJw/OcMxhjK7SkGfJtCGz/80wlxS0";
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL5LI8aGsOSdSD/WNHZBE7+cXQ82KR6zqSaL3yt311X8" ];
  };

  environment.systemPackages = with pkgs; [
    git
    gnupg
    htop
    neovim
  ];

  programs = {
    tmux.enable = true;
    gnupg.agent.enable = true;
  };

  services = {
    tlp.enable = true;
    auto-cpufreq.enable = true;
  };

  virtualisation.oci-containers = {
    backend = "podman";

    containers = {
      "embyserver" = {
        autoStart = true;
        image = "emby/embyserver:latest";
        ports = [
          "8096:8096"
          "8920:8920"
        ];
        volumes = [
          "/config/emby:/config"
          "/mnt/share:/mnt"
        ];
      };

      "samba" = {
        autoStart = true;
        cmd = [
          "-n"
          "-p"
          "-u public;password"
          "-snas;/share;yes;no;yes;all;no;"
        ];
        environment = {
          TZ = "EST5EDT";
        };
        image = "dperson/samba:latest";
        ports = [
          "139:139"
          "445:445"
        ];
        volumes = [
          "/mnt/share/nas:/share"
        ];
      };

      "nextpvr" = {
        autoStart = true;
        extraOptions = [
          "--device=/dev/dvb"
        ];
        image = "nextpvr/nextpvr_amd64:stable";
        ports = [
          "8866:8866"
          "16891:16891/udp"
        ];
        volumes = [
          "/config/nextpvr:/config"
          "/mnt/share/pvr:/recordings"
          "/mnt/share/pvr:/buffer"
        ];
      };

      "zap2xml" = {
        autoStart = true;
        environment = {
          USERNAME = "{{ZAP_USERNAME}}";
          PASSWORD = "{{ZAP_PASSWORD}}";
          OPT_ARGS = "-I -D";
          XMLTV_FILENAME = "xmltv.xml";
        };
        image = "shuaiscott/zap2xml";
        volumes = [
          "/config/nextpvr/listings:/data"
        ];
      };

      "duplicity" = {
        autoStart = true;
        environment = {
          JOB_500_WHAT = "dup full $SRC $DST $OPTIONS_EXTRA";
          JOB_500_WHEN = "weekly";
          OPTIONS_EXTRA = "--metadata-sync-mode partial --full-if-older-than 1W --file-prefix-archive archive-ashley- --file-prefix-manifest manifest-ashley- --file-prefix-signature signature-ashley-";
          PASSPHRASE = "{{DUP_PASSPHRASE}}";
          DST = "b2://{{DUP_KEYID}}:{{DUP_KEY}}@{{DUP_BUCKET}}";
          SRC = "/share";
        };
        extraOptions = [
          "--hostname"
          "--domainname"
        ];
        image = "tecnativa/duplicity:latest";
        volumes = [
          "/mnt/share/nas:/share:ro"
        ];
      };
    };
  };
}
