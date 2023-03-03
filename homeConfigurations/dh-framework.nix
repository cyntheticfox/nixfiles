{ pkgs, ... }: {
  home.packages = with pkgs; [
    burpsuite
    mozwire
    obs-studio
    openshot-qt
    postman
    virt-manager
    virt-viewer
    wl-color-picker
  ];

  # Using my home-manager modules
  sys = {
    cloud = {
      enable = true;

      manageAwsConfig = true;
      manageAzureConfig = true;
      manageGcpConfig = true;
    };

    core = {
      enable = true;

      manageFilePackages.enable = true;
      manageNetworkPackages.enable = true;
      manageProcessPackages.enable = true;
    };

    desktop = {
      enable = true;

      chat = {
        discord.enable = true;

        matrix = {
          enable = true;

          autostart = true;
          package = pkgs.nixpkgs-unstable.nheko;
        };
      };

      chromium = {
        enable = true;

        package = pkgs.ungoogled-chromium;
      };

      edge.enable = true;
      firefox.enable = true;
      ghidra.enable = true;

      games = {
        retroarch.enable = true;
        steam.enable = true;
        minecraft.enable = true;
      };

      remmina = {
        enable = true;

        package = pkgs.remmina.override {
          freerdp = pkgs.freerdp.override {
            openssl = pkgs.openssl_1_1;
          };
        };
      };

      sway = {
        enable = true;

        package = pkgs.nixpkgs-unstable.sway;
      };

      teams = {
        enable = true;

        package = pkgs.nixpkgs-unstable.teams-for-linux;
        desktopEntry = "teams-for-linux.desktop";
      };
    };

    dev.enable = true;
    fonts.enable = true;

    git = {
      enable = true;

      package = pkgs.nixpkgs-unstable.git;

      name = "David Houston";
      email = "houstdav000@gmail.com";
      gpgkey = "5960278CE235F821!";
    };

    keyboard.enable = true;
    music.enable = true;
    neovim.enable = true;
    podman.enable = true;
    sec.enable = true;

    shell = {
      enable = true;

      fcp = true;
    };

    ssh.enable = true;

    video.ffmpeg = {
      enable = true;

      package = pkgs.ffmpeg-full;
    };

    video.mpv.enable = true;
  };

  xdg.configFile."wireplumber/main.lua.d/51-fix-dac-rate.lua".text = ''
    rule = {
      matches = {
        {
          {
            "node.name",
            "equals",
            "alsa_output.usb-xDuoo_USB_Audio_2.0_xDuoo_USB_Audio_2.0-00.analog-stereo" },
        },
      },
      apply_properties = {
        ["node.description"] = "xDuoo USB DAC",
        ["audio.rate"] = 176400, -- supports 44100 48000 88200 96000 176400 352800 and 384000 supposedly
        ["audio.format"] = "SPECIAL DSD_U32_BE", -- supposed interval is 125us
        -- ["api.alsa.period-num"] = 64,
        -- ["api.alsa.period-size"] = 256,
        -- ["api.alsa.headroom"] = 256,
      },
    }

    table.insert(alsa_monitor.rules, rule)
  '';

  home.persistence."/state/home/david" = {
    allowOther = false;

    directories = [
      ".aws"
      ".azure"
      ".config/cutter"
      ".config/dconf"
      ".config/discord"
      ".config/gcloud"
      ".config/lagrange"
      ".config/libvirt"
      ".config/microsoft-edge"
      ".config/nheko"
      ".config/obs-studio"
      ".config/pipewire"
      ".config/teams"
      ".config/teams-for-linux"
      ".docker"
      ".gnupg"
      ".mozilla"
      ".ssh"
      "archive"
      "docs"
      "emu"
      "games"
      "music"
      "pics"
      "repos"
      "videos"
    ];

    files = [
      "wallpaper.png"
      "lockscreen.jpg"
      ".local/share/beets/musiclibrary.db"
      ".config/pavucontrol.ini"
    ];
  };

  home.persistence."/persist/home/david" = {
    allowOther = false;

    directories = [
      ".cache/fontconfig"
      ".cache/mesa_shader_cache"
      ".cache/mopidy"
      ".cache/nheko"
      ".cache/pre-commit"
      ".cache/virt-manager"
      ".cargo/registry"
      ".local/share/PrismLauncher"
      ".local/share/Steam"
      ".local/share/bash"
      ".local/share/containers"
      ".local/share/direnv/allow"
      ".local/share/keyrings"
      ".local/share/libvirt"
      ".local/share/mime"
      ".local/share/mopidy"
      ".local/share/nvim/site"
      ".local/share/zoxide"
      ".local/share/zsh"
      ".local/state/wireplumber"
      ".minikube/cache"
      ".terraform.d"
      "dbg"
      "iso"
      "opt"
      "tmp"
      "wrk"
    ];

    files = [
      ".local/share/beets/import.log"
      ".local/share/nix/trusted-settings.json"
    ];
  };
}
