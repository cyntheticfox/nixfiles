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

  remminaModule = packageModule {
    package = "remmina";
    name = "Remmina";

    defaultEnable = true;
    extraOptions.startService = mkEnableOption "Start the remmina service in the background" // { default = true; };
  };

  gamesModule = types.submodule (_: {
    options = {
      enable = mkEnableOption "Configure desktop games";

      steam = mkOption {
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

      itch = mkOption {
        type = packageModule {
          package = "itch";
          name = "Itch.io Launcher";
        };

        default = { };

        description = ''
          Configure the Itch.io launcher
        '';
      };

      lutris = mkOption {
        type = packageModule {
          package = "lutris";
          name = "Lutris";
        };

        default = { };
      };

      retroarch = mkOption {
        type = packageModule {
          package = "retroarchFull";
          name = "Retroarch Emulation Framework";
        };

        default = { };
      };

      minecraft = mkOption {
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
    };
  });
in
{
  options.sys.desktop = {
    enable = mkEnableOption "Configure desktop environment, packages";

    defaultBrowser = mkOption {
      type = with types; nullOr (enum [ "chromium" "firefox" ]);
      default = null;

      description = ''
        Browser to set as the default via desktop files.
      '';
    };

    chromium = mkEnableOption "Enable Chromium configuration" // { default = true; };
    discord = mkEnableOption "Enable Discord configuration";
    element = mkEnableOption "Enable Element configuration";
    edge = mkEnableOption "Enable Microsoft Edge configuration";
    firefox = mkEnableOption "Enable Firefox configuration" // { default = true; };
    ghidra = mkEnableOption "Enable Ghidra configuration";
    kitty = mkEnableOption "Enable Kitty Terminal emulator" // { default = true; };

    games = mkOption {
      type = gamesModule;
      default = { };

      description = ''
        Enable games for desktop play.
      '';
    };

    remmina = mkOption {
      type = remminaModule;
      default = { };

      description = ''
        Configuration options for Remmina, a remote desktop client supporting
        SSH, VNC, RDP, and more.
      '';
    };

    teams = mkEnableOption "Provide MS Teams as a desktop app.";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = with pkgs; [
        pcmanfm
        xdg_utils
      ];

      # # TODO: Get this to actually work
      # services.gnome-keyring = {
      #   enable = true;
      #   components = [ "secrets" ];
      # };

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

    (mkIf cfg.chromium {
      programs.chromium = {
        enable = true;
        package = pkgs.ungoogled-chromium;
      };
    })

    (mkIf cfg.discord {
      home.packages = with pkgs; [ discord ];

      xdg.configFile."discord/settings.json".source = (pkgs.formats.json { }).generate "settings.json" {
        IS_MAXIMIZED = true;
        IS_MINIMIZED = false;
        SKIP_HOST_UPDATE = true;
      };
    })

    (mkMerge [
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
    ])

    (mkIf cfg.element {
      home.packages = with pkgs; [ element-desktop ];

      home.sessionVariables."NIXOS_OZONE_WL" = 1;
    })

    (mkIf cfg.edge {
      home.packages = with pkgs; [ microsoft-edge ];
    })

    (mkIf cfg.firefox {
      xdg.configFile."tridactyl/tridactylrc".text = ''
        " General Settings
        set update.lastchecktime 1652120990699
        set update.lastnaggedversion 1.22.1
        set update.nag true
        set update.nagwait 7
        set update.checkintervalsecs 86400
        set configversion 2.0
        set theme dark
        set completions.Bmark.autoselect false
        set completions.Goto.autoselect true
        set completions.Tab.autoselect true
        set completions.TabAll.autoselect true
        set completions.Rss.autoselect true
        set completions.Sessions.autoselect true
        set modeindicatorshowkeys true
        set incsearch true
        set Ss viewconfig
        set allowautofocus false

        " Search Engines
        set searchengine startpage
        set searchurls.startpage https://www.startpage.com/do/dsearch?query=%s
        set searchurls.duckduckgo https://duckduckgo.com/?q=

        set searchurls.google https://www.google.com/search?q=
        set searchurls.bing https://www.bing.com/search?q=
        set searchurls.yahoo https://search.yahoo.com/search?p=

        set searchurls.github https://github.com/search?utf8=✓&q=
        set searchurls.mdn https://developer.mozilla.org/en-US/search?q=

        set searchurls.nixpkgs https://search.nixos.org/packages?channel=22.05&from=0&size=50&sort=relevance&type=packages&query=

        set searchurls.wikipedia https://en.wikipedia.org/wiki/Special:Search/
        set searchurls.scholar https://scholar.google.com/scholar?q=

        set searchurls.osm https://www.openstreetmap.org/search?query=
        set searchurls.gmaps https://www.google.com/maps/search/

        set searchurls.twitter https://twitter.com/search?q=
        set searchurls.youtube https://www.youtube.com/results?search_query=

        set searchurls.amazon https://www.amazon.com/s/ref=nb_sb_noss?url=search-alias%3Daps&field-keywords=

        set searchurls.arch_wiki https://wiki.archlinux.org/index.php?search=
        set searchurls.nixos_wiki https://nixos.wiki/index.php?search=

        set searchurls.searx https://searx.me/?category_general=on&q=
        set searchurls.cnrtl http://www.cnrtl.fr/lexicographie/
        set searchurls.qwant https://www.qwant.com/?q=

        " Default bindings
        bind ;x hint -F e => { const pos = tri.dom.getAbsoluteCentre(e); tri.excmds.exclaim_quiet("xdotool mousemove --sync " + window.devicePixelRatio * pos.x + " " + window.devicePixelRatio * pos.y + "; xdotool click 1")}
        bind ;X hint -F e => { const pos = tri.dom.getAbsoluteCentre(e); tri.excmds.exclaim_quiet("xdotool mousemove --sync " + window.devicePixelRatio * pos.x + " " + window.devicePixelRatio * pos.y + "; xdotool keydown ctrl+shift; xdotool click 1; xdotool keyup ctrl+shift")}
        bind <A-p> pin
        bind <A-m> mute toggle
        bind <F1> help
        bind ]] followpage next
        bind [[ followpage prev
        bind [c urlincrement -1
        bind ]c urlincrement 1
        bind <C-x> urlincrement -1
        bind <C-a> urlincrement 1
        bind yy clipboard yank
        bind ys clipboard yankshort
        bind yc clipboard yankcanon
        bind ym clipboard yankmd
        bind yo clipboard yankorg
        bind yt clipboard yanktitle
        bind gh home
        bind gH home true
        bind p clipboard open
        bind P clipboard tabopen
        bind j scrollline 10
        bind <C-e> scrollline 10
        bind k scrollline -10
        bind <C-y> scrollline -10
        bind h scrollpx -50
        bind l scrollpx 50
        bind G scrollto 100
        bind gg scrollto 0
        bind <C-u> scrollpage -0.5
        bind <C-d> scrollpage 0.5
        bind <C-f> scrollpage 1
        bind <C-b> scrollpage -1
        bind <C-v> nmode ignore 1 mode normal
        bind $ scrollto 100 x
        bind ^ scrollto 0 x
        bind H back
        bind L forward
        bind <C-o> jumpprev
        bind <C-i> jumpnext
        bind d tabclose
        bind D composite tabprev; tabclose #
        bind gx0 tabclosealltoleft
        bind gx$ tabclosealltoright
        bind << tabmove -1
        bind >> tabmove +1
        bind u undo
        bind U undo window
        bind r reload
        bind R reloadhard
        bind gi focusinput -l
        bind g? rot13
        bind g! jumble
        bind g; changelistjump -1
        bind J tabprev
        bind K tabnext
        bind gt tabnext_gt
        bind gT tabprev
        bind g^ tabfirst
        bind g0 tabfirst
        bind g$ tablast
        bind ga tabaudio
        bind gr reader
        bind gu urlparent
        bind gf viewsource
        bind : fillcmdline_notrail
        bind f hint
        bind F hint -b
        bind gF hint -qb
        bind ;i hint -i
        bind ;b hint -b
        bind ;o hint
        bind ;I hint -I
        bind ;k hint -k
        bind ;K hint -K
        bind ;y hint -y
        bind ;Y hint -cF img i => tri.excmds.yankimage(tri.urlutils.getAbsoluteURL(i.src))
        bind ;p hint -p
        bind ;h hint -h
        bind ;P hint -P
        bind ;r hint -r
        bind ;s hint -s
        bind ;S hint -S
        bind ;a hint -a
        bind ;A hint -A
        bind ;; hint -; *
        bind ;# hint -#
        bind ;v hint -W mpvsafe
        bind ;V hint -V
        bind ;w hint -w
        bind ;t hint -W tabopen
        bind ;O hint -W fillcmdline_notrail open
        bind ;W hint -W fillcmdline_notrail winopen
        bind ;T hint -W fillcmdline_notrail tabopen
        bind ;z hint -z
        bind ;m composite hint -Jpipe img src | open images.google.com/searchbyimage?image_url=
        bind ;M composite hint -Jpipe img src | tabopen images.google.com/searchbyimage?image_url=
        bind ;gi hint -qi
        bind ;gI hint -qI
        bind ;gk hint -qk
        bind ;gy hint -qy
        bind ;gp hint -qp
        bind ;gP hint -qP
        bind ;gr hint -qr
        bind ;gs hint -qs
        bind ;gS hint -qS
        bind ;ga hint -qa
        bind ;gA hint -qA
        bind ;g; hint -q;
        bind ;g# hint -q#
        bind ;gv hint -qW mpvsafe
        bind ;gw hint -qw
        bind ;gb hint -qb
        bind ;gF hint -qb
        bind ;gf hint -q
        bind <S-Insert> mode ignore
        bind <AC-Escape> mode ignore
        bind <AC-`> mode ignore
        bind <S-Escape> mode ignore
        bind <Escape> composite mode normal ; hidecmdline
        bind <C-[> composite mode normal ; hidecmdline
        bind zi zoom 0.1 true
        bind zo zoom -0.1 true
        bind zm zoom 0.5 true
        bind zr zoom -0.5 true
        bind zM zoom 0.5 true
        bind zR zoom -0.5 true
        bind zz zoom 1
        bind zI zoom 3
        bind zO zoom 0.3
        bind . repeat

        " Qutebrowser-style keybinds
        unbind pp
        unbind Pp
        unbind a
        unbind A
        unbind w
        unbind W
        unbind t
        unbind x
        unbind s
        unbind S
        unbind ZZ
        bind o fillcmdline open
        bind O fillcmdline tabopen
        bind M bmark
        bind T fillcmdline tab
        bind b fillcmdline bmarks
        bind B fillcmdline bmarks -t
        bind gU composite tabduplicate; urlparent
        bind v mode visual
        bind wp clipboard winopen
        bind wo fillcmdline winopen
        bind / fillcmdline find
        bind ? fillcmdline find -?
        bind n findnext 1
        bind N findnext -1
        bind ,<Space> nohlsearch
        bind <C-h> home
        bind <C-q> qall
        bind gC tabduplicate
        bind gD tabdetach
        bind ss fillcmdline set
        bind sf fillcmdline mkt
        bind sk fillcmdline bind
        bind <C-s> stop
        bind go current_url open
        bind gO current_url tabopen
        bind wi viewsource
        bind gK tabmove +1
        bind gJ tabmove -1
        bind gm tabmove
        bind xo fillcmdline tabopen -b
        bind gd fillcmdline saveas
        bind co tabonly
        bind xO current_url tabopen -b
        bind yY clipboard yank
        bind yp clipboard yank

        " Aliases
        alias save mktridactylrc
        command alias command
        alias au autocmd
        alias aucon autocontain
        alias audel autocmddelete
        alias audelete autocmddelete
        alias blacklistremove autocmddelete DocStart
        alias b tab
        alias clsh clearsearchhighlight
        alias nohlsearch clearsearchhighlight
        alias noh clearsearchhighlight
        alias o open
        alias w winopen
        alias t tabopen
        alias tabnew tabopen
        alias tabm tabmove
        alias tabo tabonly
        alias tn tabnext_gt
        alias bn tabnext_gt
        alias tnext tabnext_gt
        alias bnext tabnext_gt
        alias tp tabprev
        alias tN tabprev
        alias bp tabprev
        alias bN tabprev
        alias tprev tabprev
        alias bprev tabprev
        alias tabfirst tab 1
        alias tablast tab 0
        alias bfirst tabfirst
        alias blast tablast
        alias tfirst tabfirst
        alias tlast tablast
        alias buffer tab
        alias bufferall taball
        alias bd tabclose
        alias bdelete tabclose
        alias quit tabclose
        alias q tabclose
        alias qa qall
        alias sanitize sanitise
        alias saveas! saveas --cleanup --overwrite
        alias tutorial tutor
        alias h help
        alias unmute mute unmute
        alias authors credits
        alias openwith hint -W
        alias ! exclaim
        alias !s exclaim_quiet
        alias containerremove containerdelete
        alias colours colourscheme
        alias colorscheme colourscheme
        alias colors colourscheme
        alias man help
        alias !js fillcmdline_tmp 3000 !js is deprecated. Please use js instead
        alias !jsb fillcmdline_tmp 3000 !jsb is deprecated. Please use jsb instead
        alias get_current_url js document.location.href
        alias current_url composite get_current_url | fillcmdline_notrail
        alias stop js window.stop()
        alias zo zoom
        alias installnative nativeinstall
        alias nativeupdate updatenative
        alias mkt mktridactylrc
        alias mkt! mktridactylrc -f
        alias mktridactylrc! mktridactylrc -f
        alias mpvsafe js -p tri.excmds.shellescape(JS_ARG).then(url => tri.excmds.exclaim_quiet('mpv --no-terminal ' + url))
        alias drawingstop no_mouse_mode
        alias exto extoptions
        alias extpreferences extoptions
        alias extp extpreferences
        alias prefset setpref
        alias prefremove removepref
        alias tabclosealltoright tabcloseallto right
        alias tabclosealltoleft tabcloseallto left
        alias reibadailty jumble

        " For syntax highlighting see https://github.com/tridactyl/vim-tridactyl
        " vim: set filetype=tridactyl
      '';

      programs.firefox = {
        enable = true;

        package = pkgs.firefox.override {
          # forceWayland = true;
          cfg.enableTridactylNative = true;
        };
      };
    })

    (mkIf ((cfg.chromium || cfg.firefox) && cfg.defaultBrowser != null) (
      let
        primary-browser =
          if
            cfg.defaultBrowser == "firefox"
          then
            {
              name = "firefox";
              bin = "${config.programs.firefox.package}/bin/firefox";
              xdg-desktop = "firefox.desktop";
            }
          else
            {
              name = "chromium";
              bin = "${config.programs.chromium.package}/bin/chromium";
              xdg-desktop = "chromium.desktop";
            };

        setFileAssociation = list: lib.genAttrs list (_: primary-browser.xdg-desktop);
      in
      {
        home.sessionVariables.BROWSER = primary-browser.bin;

        xdg.mimeApps.defaultApplications = setFileAssociation [
          "text/html"
          "text/xml"
          "application/xhtml+xml"
          "application/xml"
          "application/rdf+xml"
          "image/gif"
          "image/jpeg"
          "image/png"
          "x-scheme-handler/ftp"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ];
      }
    ))

    (mkIf cfg.ghidra {
      home.packages = with pkgs; [ ghidra ];
    })

    (
      let
        theme = "nord";
        themeFile = "${theme}.conf";
      in
      mkIf cfg.kitty {
        home.sessionVariables.TERMINAL = "${pkgs.kitty}/bin/kitty";

        programs.kitty = {
          enable = true;

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

          extraConfig = ''
            include ./${themeFile}
          '';
        };

        xdg.configFile."kitty/${themeFile}".source =
          let
            owner = "connorholyday";
            repo = "nord-kitty";
            rev = "3a819c1f207cd2f98a6b7c7f9ebf1c60da91c9e9";
            sha256 = "sha256:1fbnc6r9mbqb6wxqqi9z8hjhfir44rqd6ynvbc49kn6gd8v707p1";
          in
          pkgs.fetchurl {
            inherit sha256;

            url = "https://raw.githubusercontent.com/${owner}/${repo}/${rev}/${themeFile}";
          };

      }
    )

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
              PartOf = [ "graphical-session.target" ];
            };

            Install.WantedBy = [ "graphical-session.target" ];

            Service = {
              Type = "simple";
              ExecStart = "${cfg.remmina.package}/bin/remmina -i";
            };
          };
        })
      ])
    )

    (mkIf cfg.teams {
      home.packages = with pkgs; [
        nixpkgs-unstable.teams
      ];

      xdg.mimeApps.defaultApplications."x-scheme-handler/msteams" = "teams.desktop";

      # For whatever reason, teams likes to overwrite the mimetypes, even if it's
      #   fine. So, add a step to activation to remove the file if it's not a link.
      #
      home.activation.remove-mimeapps =
        let
          filename = "${config.xdg.configHome}/mimeapps.list";
        in
        lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
          if [ -e ${filename} ]; then
            if [ ! -L ${filename} ]; then
              $DRY_RUN_CMD rm $VERBOSE_ARG ${filename}
            fi
          fi
        '';
    })
  ]);
}
