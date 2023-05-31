{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.sys.desktop;

  packageModule = { package, name, extraOptions ? { }, defaultEnable ? false }: types.submodule (_: {
    options = {
      enable = mkEnableOption "Enable ${name} configuration" // { default = defaultEnable; };

      package = mkPackageOption pkgs package { };
    } // extraOptions;
  });

  multipackageModule = { description, defaultPackages ? [ ], defaultEnable ? false, extraOptions ? { } }: types.submodule (_: {
    options = {
      enable = mkEnableOption description // { default = defaultEnable; };

      packages = mkOption {
        type = with types; listOf package;
        default = defaultPackages;
      };
    } // extraOptions;
  });
in
{
  options.sys.desktop = {
    enable = mkEnableOption "Configure desktop environment, packages";

    defaultEditor = mkOption {
      type = with types; nullOr (enum [ "vscode" "neovim-qt" ]);
      default = "neovim-qt";

      description = "Editor to set as default via environment variables.";
    };

    defaultPDFViewer = mkOption {
      type = with types; nullOr (enum [ "mupdf" ]);
      default = "mupdf";

      description = ''
        Editor to set as default via environment variables.
      '';
    };

    defaultTerminal = mkOption {
      type = with types; nullOr (enum [ "kitty" ]);
      default = "kitty";

      description = ''
        Terminal to set as default via environment variables.
      '';
    };

    ghidra = mkOption {
      type = packageModule {
        name = "Ghidra";
        package = "ghidra";
      };

      default = { };
    };

    edge = mkOption {
      type = packageModule {
        name = "Microsoft Edge";
        package = "microsoft-edge";
      };

      default = { };
    };

    kitty = mkOption {
      type = packageModule {
        defaultEnable = true;
        name = "Kitty";
        package = "kitty";
      };

      default = { };
    };

    chromium = mkOption {
      type = packageModule {
        name = "Chromium";
        package = "chromium";
      };

      default = { };
    };

    mupdf = mkOption {
      type = packageModule {
        defaultEnable = true;
        name = "MuPDF";
        package = "mupdf";
      };

      default = { };
    };

    libreoffice = mkOption {
      type = packageModule {
        defaultEnable = true;
        package = "libreoffice";
        name = "LibreOffice";
      };

      default = { };
    };

    neovim-qt = mkOption {
      type = packageModule {
        defaultEnable = config.sys.neovim.enable or false;
        package = "neovim-qt";
        name = "Neovim QT";
      };

      default = { };
    };

    vscode = mkOption {
      type = packageModule {
        defaultEnable = !(config.sys.neovim.enable or false);
        package = "vscode";
        name = "Visual Studio Code";
      };

      default = { };
    };

    games.steam = mkOption {
      type = packageModule {
        package = "steam";
        name = "Steam";

        extraOptions.wine = mkOption {
          type = multipackageModule {
            description = ''
              Additional packages to enable for Windows game support. Adds wine-wayland by default.
            '';

            defaultEnable = true;

            defaultPackages = with pkgs; [
              winetricks
              wine-wayland
              protontricks
            ];
          };

          default = { };
        };
      };

      default = { };

      description = ''
        Configure Valve's Steam launcher.
      '';
    };

    games.itch = mkOption {
      type = packageModule {
        package = "itch";
        name = "Itch.io Launcher";
      };

      default = { };

      description = ''
        Configure the Itch.io launcher
      '';
    };

    games.lutris = mkOption {
      type = packageModule {
        package = "lutris";
        name = "Lutris";
      };

      default = { };
    };

    games.retroarch = mkOption {
      type = packageModule {
        package = "retroarchFull";
        name = "Retroarch Emulation Framework";
      };

      default = { };
    };

    games.minecraft = mkOption {
      type = packageModule {
        package = "minecraft";
        name = "Minecraft";

        extraOptions.extraLaunchers = mkOption {
          type = multipackageModule {
            description = ''
              Enable additional launchers for modded Minecraft or easier use.
            '';

            defaultPackages = with pkgs; [ prismlauncher ];
          };

          default = { };
        };
      };

      default = { };
    };

    remmina = mkOption {
      type = packageModule {
        package = "remmina";
        name = "Remmina";

        defaultEnable = true;
        extraOptions.startService = mkEnableOption "Start the remmina service in the background" // { default = true; };
      };

      default = { };

      description = ''
        Configuration options for Remmina, a remote desktop client supporting
        SSH, VNC, RDP, and more.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      #   home.packages = with pkgs; [
      #     pcmanfm
      #     xdg_utils
      #     gnome.gnome-keyring
      #   ];
      #
      #   systemd.user.sockets.gnome-keyring-daemon = {
      #     Unit = {
      #       Description = "GNOME Keyring daemon";
      #       Documentation = "man:gnome-keyring-daemon(1)";
      #     };
      #
      #     Socket = {
      #       Priority = 6;
      #       Backlog = 5;
      #       ListenStream = "%t/keyring/control";
      #       DirectoryMode = "0700";
      #     };
      #
      #     Install.WantedBy = [ "sockets.target" ];
      #   };
      #
      #   systemd.user.services.gnome-keyring-daemon = {
      #     Unit = {
      #       Description = "GNOME Keyring daemon";
      #       Documentation = "man:gnome-keyring-daemon(1)";
      #       PartOf = [ "secrets-service.target" ];
      #       Requires = [ "gnome-keyring-daemon.socket" ];
      #     };
      #
      #     Service = {
      #       Type = "simple";
      #       StandardError = "journal";
      #       ExecStart = keyringCmd;
      #       BusName = [
      #         "org.freedesktop.impl.portal.Secret"
      #         "org.freedesktop.secrets"
      #         "org.gnome.keyring"
      #       ];
      #       Restart = "on-failure";
      #     };
      #
      #     Install = {
      #       Also = [ "gnome-keyring-daemon.socket" ];
      #       RequiredBy = [ "secrets-service.target" ];
      #     };
      #   };
      #
      #   xdg.dataFile =
      #     let
      #       mapListToAttrs' = f: list: builtins.listToAttrs (builtins.map f list);
      #
      #       files = [
      #         "org.freedesktop.impl.portal.Secret"
      #         "org.freedesktop.secrets"
      #         "org.gnome.keyring"
      #       ];
      #     in
      #     mapListToAttrs'
      #       (f: {
      #         name = "dbus-1/services/${f}.service";
      #         value = {
      #           text = ''
      #             [D-BUS Service]
      #             Name=${f}
      #             Exec=${keyringCmd}
      #           '';
      #         };
      #       })
      #       files;

      # TODO: Replace when home-manager/release-22.11
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

      home.shellAliases."open" = "xdg-open";

      xdg.mime.enable = true;
      xdg.mimeApps.enable = true;

      # Reload mime type associations on activation
      home.activation.reload-mimetypes = lib.hm.dag.entryAfter [ "writeBoundary" "checkLinkTargets" ] ''
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p $VERBOSE_ARG ${config.xdg.dataHome}/mime/packages
        $DRY_RUN_CMD ${pkgs.shared-mime-info}/bin/update-mime-database $VERBOSE_ARG ${config.xdg.dataHome}/mime
      '';
    }

    (mkIf cfg.chromium.enable {
      programs.chromium = {
        inherit (cfg.chromium) enable;

        package = pkgs.ungoogled-chromium;
      };
    })

    (mkIf cfg.games.steam.enable (mkMerge [
      { home.packages = [ cfg.games.steam.package ]; }

      (mkIf cfg.games.steam.wine.enable {
        home.packages = cfg.games.steam.wine.packages;
      })
    ]))

    (mkIf cfg.games.itch.enable {
      home.packages = [ cfg.games.itch.package ];
    })

    (mkIf cfg.games.lutris.enable {
      home.packages = [ cf.games.lutris.package ];
    })

    (mkIf cfg.games.minecraft.enable (mkMerge [
      { home.packages = [ cfg.games.minecraft.package ]; }

      (mkIf cfg.games.minecraft.extraLaunchers.enable {
        home.packages = cfg.games.minecraft.extraLaunchers.packages;
      })
    ]))

    (mkIf cfg.neovim-qt.enable {
      home.packages = [ cfg.neovim-qt.package ];
    })

    (mkIf cfg.vscode.enable {
      home.packages = [ cfg.vscode.package ];
    })

    (mkIf (cfg.defaultEditor != null) {
      home.sessionVariables =
        let
          path = lib.getExe cfg.${cfg.defaultEditor}.package;
        in
        {
          EDITOR_GRAPHICAL = path;
          VISUAL_GRAPHICAL = path;
        };
    })

    (mkIf cfg.edge.enable {
      home.packages = [ cfg.edge.package ];
    })

    (mkIf cfg.mupdf.enable {
      home.packages = [ cfg.mupdf.package ];
    })

    (mkIf cfg.libreoffice.enable {
      home.packages = [ cfg.libreoffice.package ];
    })

    (mkIf (cfg.defaultPDFViewer != null) {
      xdg.mimeApps.defaultApplications =
        let
          app = "${cfg.defaultPDFViewer}.desktop";
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

    (mkIf cfg.ghidra.enable {
      home.packages = [ cfg.ghidra.package ];
    })

    (mkIf cfg.kitty.enable {
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

    (mkIf (cfg.defaultTerminal != null) {
      home.sessionVariables.TERMINAL = lib.getExe cfg.${cfg.defaultTerminal}.package;
    })

    (mkIf cfg.remmina.enable (
      mkMerge [
        {
          home.packages = [ cfg.remmina.package ];

          xdg.mimeApps.defaultApplications."application/x-rdp" = "org.remmina.Remmina.desktop";

          xdg.dataFile."mime/packages/application-x-rdp.xml".text = ''
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
        }

        (mkIf cfg.remmina.startService {
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
      ])
    )
  ]);
}
