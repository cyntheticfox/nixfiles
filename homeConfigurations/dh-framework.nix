{ pkgs, ... }: {
  imports = [
    ../home-manager/config/sway.nix

    # GUI modules
    ../home-manager/config/gui/networking.nix
    ../home-manager/config/gui/video.nix
  ];

  home.packages = with pkgs; [
    postman
    mozwire
    virt-manager
    virt-viewer
    wl-color-picker
  ];

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

      defaultBrowser = "firefox";
      discord = true;
      edge = true;
      element = true;

      games = {
        enable = true;

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

      teams = true;
    };

    dev.enable = true;
    fonts.enable = true;

    git = {
      enable = true;

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
}
