{ config, lib, pkgs, ... }:

let
  cfg = config.sys.desktop;

  packageModule = { package, name, extraOptions ? { }, defaultEnable ? false }: lib.types.submodule (_: {
    options = {
      enable = lib.mkEnableOption "Enable ${name} configuration" // { default = defaultEnable; };

      package = lib.mkPackageOption pkgs package { };
    } // extraOptions;
  });
in
{
  options.sys.desktop = {
    enable = lib.mkEnableOption "Configure desktop environment, packages";

    defaults = {
      editor = lib.mkOption {
        type = lib.types.enum [ "vscode" "neovim-qt" ];
        default = "neovim-qt";

        description = ''
          Editor to set as default via environment variables.
        '';
      };

      pdf = lib.mkOption {
        type = with lib.types; nullOr (enum [ "mupdf" ]);
        default = "mupdf";

        description = ''
          Editor to set as default via environment variables.
        '';
      };

      terminal = lib.mkOption {
        type = with lib.types; nullOr (enum [ "kitty" ]);
        default = "kitty";

        description = ''
          Terminal to set as default via environment variables.
        '';
      };
    };

    ghidra = lib.mkOption {
      type = packageModule {
        name = "Ghidra";
        package = "ghidra";
      };

      default = { };
    };

    kitty = lib.mkOption {
      type = packageModule {
        defaultEnable = true;
        name = "Kitty";
        package = "kitty";
      };

      default = { };
    };

    mupdf = lib.mkOption {
      type = packageModule {
        defaultEnable = true;
        name = "MuPDF";
        package = "mupdf";
      };

      default = { };
    };

    libreoffice = lib.mkOption {
      type = packageModule {
        defaultEnable = true;
        package = "libreoffice";
        name = "LibreOffice";
      };

      default = { };
    };

    neovim-qt = lib.mkOption {
      type = packageModule {
        defaultEnable = config.sys.neovim.enable or false;
        package = "neovim-qt";
        name = "Neovim QT";
      };

      default = { };
    };

    vscode = lib.mkOption {
      type = packageModule {
        defaultEnable = !(config.sys.neovim.enable or false);
        package = "vscode";
        name = "Visual Studio Code";
      };

      default = { };
    };

    games = {
      steam = lib.mkOption {
        type = packageModule {
          package = "steam";
          name = "Steam";

          extraOptions.wine = lib.mkOption {
            type = with lib.types; listOf package;

            default = with pkgs; [
              winetricks
              wine-wayland
              protontricks
            ];

            description = ''
              Additional packages to enable for Windows game support. Adds wine-wayland by default.
            '';
          };
        };

        default = { };

        description = ''
          Configure Valve's Steam launcher.
        '';
      };

      itch = lib.mkOption {
        type = packageModule {
          package = "itch";
          name = "Itch.io Launcher";
        };

        default = { };

        description = ''
          Configure the Itch.io launcher
        '';
      };

      lutris = lib.mkOption {
        type = packageModule {
          package = "lutris";
          name = "Lutris";
        };

        default = { };
      };

      retroarch = {
        enable = lib.mkEnableOption "Retroarch Emulation Framework";
        package = lib.mkPackageOption pkgs "retroarchFull" { };
      };

      minecraft = {
        enable = lib.mkEnableOption "Minecraft";
        package = lib.mkPackageOption pkgs "minecraft" { };

        extraLaunchers = lib.mkOption {
          type = with lib.types; listOf package;
          default = with pkgs; [ prismlauncher ];

          description = ''
            Enable additional launchers for modded Minecraft or easier use.
          '';
        };
      };
    };

    remmina = lib.mkOption {
      type = packageModule {
        package = "remmina";
        name = "Remmina";

        defaultEnable = true;
        extraOptions.startService = lib.mkEnableOption "Start the remmina service in the background" // { default = true; };
      };

      default = { };

      description = ''
        Configuration options for Remmina, a remote desktop client supporting
        SSH, VNC, RDP, and more.
      '';
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # TODO: Replace when home-manager/release-23.05
      # services.pass-secret-service = {
      #   enable = true;
      #
      #   storePath = "${config.home.homeDirectory}/.local/share/password-store";
      # };
      systemd.user.services.pass-secret-service = {
        Unit = {
          AssertFileIsExecutable = "${pkgs.pass-secret-service}/bin/pass_secret_service";
          Description = "Pass libsecret service";
          Documentation = "https://github.com/mdellweg/pass_secret_service";
          PartOf = [ "secrets-service.target" ];
        };

        Service = {
          Type = "dbus";
          ExecStart = "${pkgs.pass-secret-service}/bin/pass_secret_service --path \"${config.home.homeDirectory}/.local/share/password-store\"";
          BusName = "org.freedesktop.secrets";
        };

        Install.WantedBy = [ "secrets-service.target" ];
      };

      xdg.dataFile."dbus-1/services/org.freedesktop.secrets.service".source = "${pkgs.pass-secret-service}/share/dbus-1/services/org.freedesktop.secrets.service";

      systemd.user.targets.secrets-service.Unit = {
        Description = "Setup of a FreeDesktop secrets management service";
        Documentation = "man:systemd.special(7)";
        PartOf = [ "graphical-session-pre.target" ];
      };

      services.udiskie.enable = true;

      gtk = {
        enable = true;

        theme = {
          package = pkgs.nordic;
          name = "Nordic";
        };

        iconTheme = {
          package = pkgs.papirus-icon-theme;
          name = "Papirus";
        };
      };

      qt = {
        enable = true;
        platformTheme = "gnome";

        style = {
          name = "adwaita-dark";
          package = pkgs.adwaita-qt;
        };
      };

      home = {
        shellAliases."open" = "xdg-open";
        sessionVariables =
          let
            path = lib.getExe cfg.${cfg.defaults.editor}.package;
          in
          {
            EDITOR_GRAPHICAL = path;
            VISUAL_GRAPHICAL = path;
          };

        # Reload mime type associations on activation
        activation.reload-mimetypes = lib.hm.dag.entryAfter [ "writeBoundary" "checkLinkTargets" ] ''
          $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p $VERBOSE_ARG ${config.xdg.dataHome}/mime/packages
          $DRY_RUN_CMD ${pkgs.shared-mime-info}/bin/update-mime-database $VERBOSE_ARG ${config.xdg.dataHome}/mime
        '';
      };

      xdg.mime.enable = true;
      xdg.mimeApps.enable = true;
    }

    (lib.mkIf cfg.games.steam.enable {
      home.packages = [ cfg.games.steam.package ] ++ cfg.games.steam.wine;
    })

    (lib.mkIf cfg.games.itch.enable {
      home.packages = [ cfg.games.itch.package ];
    })

    (lib.mkIf cfg.games.lutris.enable {
      home.packages = [ cfg.games.lutris.package ];
    })

    (lib.mkIf cfg.games.retroarch.enable {
      home.packages = [ cfg.games.retroarch.package ];
    })

    (lib.mkIf cfg.games.minecraft.enable {
      home.packages = [ cfg.games.minecraft.package ] ++ cfg.games.minecraft.extraLaunchers;
    })

    (lib.mkIf cfg.neovim-qt.enable {
      home.packages = [ cfg.neovim-qt.package ];
    })

    (lib.mkIf cfg.vscode.enable {
      home.packages = [ cfg.vscode.package ];
    })

    (lib.mkIf cfg.mupdf.enable {
      home.packages = [ cfg.mupdf.package ];
    })

    (lib.mkIf cfg.libreoffice.enable {
      home.packages = [ cfg.libreoffice.package ];
    })

    (lib.mkIf (cfg.defaults.pdf != null) {
      xdg.mimeApps.defaultApplications =
        let
          app = "${cfg.defaults.pdf}.desktop";
        in
        {
          "application/pdf" = app;
          "application/x-pdf" = app;
          "application/x-cbz" = app;
          "application/oxps" = app;
          "application/vnd.ms-xpsdocument" = app;
          "application/epub+zip" = app;
        };
    })

    (lib.mkIf cfg.ghidra.enable {
      home.packages = [ cfg.ghidra.package ];
    })

    (lib.mkIf cfg.kitty.enable {
      programs.kitty = {
        inherit (cfg.kitty) enable;

        settings = {
          # Set font settings
          font_family = "FiraCodeNerdFontCompleteMono-Retina";
          font_size = 12;
          font_features = "FiraCodeNerdFontCompleteMono-Retina +zero +onum";

          # Set terminal bell to off
          enable_audio_bell = false;
          visual_bell_duration = 0;

          # Fix tab bar
          tab_bar_edge = "top";
          tab_bar_style = "powerline";
          tab_bar_min_tabs = 1;
          tab_title_template = "{index}: {title}";
          tab_bar_background = "#222";

          # Set background Opacity
          background_opacity = "0.9";
        };

        extraConfig =
          let
            themefile =
              let
                owner = "connorholyday";
                repo = "nord-kitty";
                rev = "3a819c1f207cd2f98a6b7c7f9ebf1c60da91c9e9";
                sha256 = "sha256:1fbnc6r9mbqb6wxqqi9z8hjhfir44rqd6ynvbc49kn6gd8v707p1";
              in
              pkgs.fetchurl {
                inherit sha256;

                url = "https://raw.githubusercontent.com/${owner}/${repo}/${rev}/nord.conf";
              };
          in
          "include ${themefile}";
      };
    })

    (lib.mkIf (cfg.defaults.terminal != null) {
      home.sessionVariables."TERMINAL" = lib.getExe cfg.${cfg.defaults.terminal}.package;
    })

    (lib.mkIf cfg.remmina.enable (lib.mkMerge [
      {
        home.packages = [ cfg.remmina.package ];

        xdg = {
          mimeApps.defaultApplications."application/x-rdp" = "org.remmina.Remmina.desktop";

          dataFile."mime/packages/application-x-rdp.xml".text = ''
            <?xml version="1.0" encoding="UTF-8"?>
            <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
              <mime-type type="application/x-rdp">
                <comment>rdp file</comment>
                <icon name="application-x-rdp"/>
                <glob-deleteall/>
                <glob pattern="*.rdp"/>
              </mime-type>
            </mime-info>
          '';
        };
      }

      (lib.mkIf cfg.remmina.startService {
        systemd.user.services.remmina = {
          Unit = {
            Description = "Remmina remote desktop client";
            Documentation = "man:remmina(1)";
            Requires = [ "graphical-session-pre.target" "secrets-service.target" ];
            After = [ "graphial-session-pre.target" "secrets-service.target" ];
          };

          Service = {
            Type = "simple";
            ExecStart = "${lib.getExe cfg.remmina.package} --icon --enable-extra-hardening";
            Restart = "on-abort";
          };

          Install.WantedBy = [ "graphical-session.target" ];
        };
      })
    ]))
  ]);
}
