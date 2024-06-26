{
  config,
  lib,
  pkgs,
  ...
}:
{
  home = {
    packages = with pkgs; [
      # pipewire
      qpwgraph
      pulseaudioFull

      flips
      insomnia
      moar
      openshot-qt
      wl-color-picker
      zap
    ];

    persistence = {
      "/state/home" = {
        allowOther = false;

        directories = [
          ".config/cutter"
          ".config/dconf"
          ".config/discord" # TODO: Put into discord module
          ".config/lagrange"
          ".config/libvirt"
          ".config/nheko"
          ".config/obs-studio"
          ".config/pipewire"
          ".config/retroarch"
          ".config/WebCord"
          ".gnupg"
          ".mozilla"
          ".ssh"
          "archive"
          "docs"
          "emu"
          "games"
          "music"
          "pics"
          "srv"
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

      "/persist/home" = {
        allowOther = false;

        directories = [
          ".cache/fontconfig"
          ".cache/mesa_shader_cache"
          ".cache/mopidy"
          ".cache/nheko"
          ".cache/pre-commit"
          ".cache/virt-manager"
          ".local/share/PrismLauncher"
          ".local/share/Steam"
          ".local/share/bash"
          ".local/share/containers"
          ".local/share/direnv/allow"
          ".local/share/fish"
          ".local/share/libvirt"
          ".local/share/mime"
          ".local/share/mopidy"
          ".local/share/nheko"
          ".local/share/nvim/site"
          ".local/share/password-store"
          ".local/share/wineprefixes"
          ".local/share/zoxide"
          ".local/state/wireplumber"
          ".steam"
          ".wine"
          "dbg"
          "iso"
          "opt"
          "tmp"
        ];

        files = [
          ".local/share/beets/import.log"
          ".local/share/nix/trusted-settings.json"
        ];
      };
    };
  };

  programs.obs-studio.enable = true;

  sops = {
    defaultSopsFile = ./secrets.yml;
    age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
    secrets.rclone-conf.path = "${config.home.homeDirectory}/.config/rclone/rclone.conf";
  };

  # Using my home-manager modules
  sys = {
    cloud = {
      backup = {
        b2.enable = true;
        rclone.enable = true;
      };

      opentofu.enable = true;
    };

    desktop = {
      enable = true;

      chat = {
        discord = {
          enable = true;
          autostart = true;
        };

        matrix = {
          enable = true;
          autostart = true;
          package = pkgs.nixpkgs-unstable.nheko;
        };
      };

      kitty.theme = {
        enable = true;
        name = "OneDark";
      };

      games = {
        retroarch.enable = true;
        steam.enable = true;
        minecraft.enable = true;
      };

      ghidra.enable = true;
      remmina.enable = true;

      sway = {
        enable = true;
        package = pkgs.nixpkgs-unstable.sway;
      };

      web = {
        chromium = {
          enable = true;
          package = pkgs.ungoogled-chromium;
        };

        firefox.enable = true;
      };
    };

    dev.enable = true;
    fonts.enable = true;

    git = {
      enable = true;
      package = pkgs.nixpkgs-unstable.git;
      name = "Cynthia Fox";
      email = "cyntheticfox@gh0st.sh";
      gpgkey = "5960278CE235F821!";
    };

    helix = {
      enable = true;
      package = pkgs.nixpkgs-unstable.helix;
    };

    keyboard.enable = true;
    music.enable = true;
    podman.enable = true;
    sec.enable = true;

    shell = {
      enable = true;

      defaults = {
        pager = lib.getExe pkgs.moar;
        editor = lib.getExe config.sys.helix.package;
        viewer = "${lib.getExe config.sys.helix.package} -R";
      };

      fish.enable = true;
      fcp.enable = true;
    };

    ssh.enable = true;

    video.ffmpeg = {
      enable = true;
      package = pkgs.ffmpeg-full;
    };

    video.mpv.enable = true;
    virt.libvirt.enable = true;
  };

  xdg.configFile."wireplumber/main.lua.d/51-fix-dac-rate.lua".text = ''
    rule = {
      matches = {
        {
          {
            "node.name",
            "equals",
            "alsa_output.usb-xDuoo_USB_Audio_2.0_xDuoo_USB_Audio_2.0-00.analog-stereo"
          },
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
}
