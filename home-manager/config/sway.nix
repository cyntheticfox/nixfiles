{ config, pkgs, lib, ... }:
let
  screens = {
    builtin = "eDP-1";
    main = "Samsung Electric Company SMS27A350H 0x00007F36";
    sub = "ViewSonic Corporation VP211b A22050300003";

    # Functions
    screenOrder = lib.escapeShellArgs;
  };

  user-bins = {
    date = "${pkgs.coreutils}/bin/date";
    discord = "${pkgs.discord-canary}/bin/discordcanary";
    element = "${pkgs.element-desktop-wayland}/bin/element-desktop";
    grimshot = "${pkgs.sway-contrib.grimshot}/bin/grimshot";
    jq = "${pkgs.jq}/bin/jq";
    light = "${pkgs.light}/bin/light";
    loginctl = "${pkgs.systemd}/bin/loginctl";
    pamixer = "${pkgs.pamixer}/bin/pamixer";
    pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
    pkill = "${pkgs.procps}/bin/pkill";
    playerctl = "${config.services.playerctld.package}/bin/playerctl";
    rofi = "${config.programs.rofi.package}/bin/rofi";
    slurp = "${pkgs.slurp}/bin/slurp";
    swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
    swaymsg = "${config.wayland.windowManager.sway.package}/bin/swaymsg";
    systemctl = config.systemd.user.systemctlPath;
    teams = "${pkgs.teams}/bin/teams";
    waybar = "${pkgs.waybar}/bin/waybar";
    wf-recorder = "${pkgs.wf-recorder}/bin/wf-recorder";
    wlogout = "${pkgs.wlogout}/bin/wlogout";
    xargs = "${pkgs.findutils}/bin/xargs";
  };

  lockscreen = lib.concatStringsSep " " [
    "${user-bins.swaylock}"
    "--daemonize"
    "--show-failed-attempts"
    "--image ${config.home.homeDirectory}/wallpaper.png"
    "--clock"
    "--indicator"
    "--effect-blur 7x5"
    "--effect-vignette 0.5:0.5"
    "--fade-in 0.2"
  ];

  ### Workspace Configuration
  # Set a name for workspaces
  #
  workspaces = {
    _1 = "1:   Web";
    _2 = "2:   Teams";
    _3 = "3:   Element";
    _4 = "4:   Discord";
    _5 = "5:   Email";
    _6 = "6:   Etc 1";
    _7 = "7:   Etc 2";
    _8 = "8:   Etc 3";
    _9 = "9:   Etc 4";
  };
in
{
  imports = [ ./base-desktop.nix ];

  home.packages = with pkgs; [
    libnotify
  ];

  # Enable controlling players with media keys with playerctld
  services.playerctld.enable = true;

  wayland.windowManager.sway = {
    enable = true;

    package = pkgs.nixos-unstable.sway;

    wrapperFeatures.gtk = true;
    systemdIntegration = true;

    config =
      let
        # Use start/logo key for modifiers
        modifier = "Mod4";

        # Use (n)vim-like keybindings
        left = "h";
        right = "l";
        up = "j";
        down = "k";

        # Your preferred application launcher
        # NOTE: pass the final command to swaymsg so that the resulting window
        #   can be opened on the original workspace that the command was run on.
        appmenu = "${user-bins.rofi} -show drun | ${user-bins.xargs} ${user-bins.swaymsg} exec --";
        menu = "${user-bins.rofi} -show run | ${user-bins.xargs} ${user-bins.swaymsg} exec --";
        todomenu = "${pkgs.todofi-sh}/bin/todofi.sh";

        # Shutdown command
        shutdown = "${user-bins.wlogout} --buttons-per-row 3";
      in
      {
        inherit modifier left right up down;

        # Set the terminal
        terminal = config.home.sessionVariables.TERMINAL;

        # Configure XWayland seat
        seat.seat0.hide_cursor = "when-typing enable";

        # Use some of the default keybindings w/ `lib.mkOptionDefault`
        keybindings = lib.mkOptionDefault {
          # Media key bindings
          "XF86AudioMute" = "exec ${user-bins.pamixer} -t";
          "XF86AudioNext" = "exec ${user-bins.playerctl} next";
          "XF86AudioPlay" = "exec ${user-bins.playerctl} play-pause";
          "XF86AudioPrev" = "exec ${user-bins.playerctl} previous";
          "XF86AudioLowerVolume" = "exec ${user-bins.pamixer} -d 2";
          "XF86AudioRaiseVolume" = "exec ${user-bins.pamixer} -i 2";
          "XF86AudioStop" = "exec ${user-bins.playerctl} stop";

          # Screen brightness bindings
          "XF86MonBrightnessDown" = "exec '${user-bins.light} -U 5'";
          "XF86MonBrightnessUp" = "exec '${user-bins.light} -A 5'";

          # Capture PowerOff key
          "XF86PowerOff" = "exec ${shutdown}";

          # Redefine menu bindings
          "${modifier}+d" = "exec ${appmenu}";
          "${modifier}+Shift+d" = "exec ${menu}";
          "${modifier}+t" = "exec ${todomenu}";

          # Define our own shutdown command
          "${modifier}+Shift+e" = "exec ${shutdown}";

          # Define our own workspace switchers
          "${modifier}+1" = "workspace \"${workspaces._1}\"";
          "${modifier}+2" = "workspace \"${workspaces._2}\"";
          "${modifier}+3" = "workspace \"${workspaces._3}\"";
          "${modifier}+4" = "workspace \"${workspaces._4}\"";
          "${modifier}+5" = "workspace \"${workspaces._5}\"";
          "${modifier}+6" = "workspace \"${workspaces._6}\"";
          "${modifier}+7" = "workspace \"${workspaces._7}\"";
          "${modifier}+8" = "workspace \"${workspaces._8}\"";
          "${modifier}+9" = "workspace \"${workspaces._9}\"";

          "${modifier}+Shift+1" = "move container to workspace \"${workspaces._1}\"";
          "${modifier}+Shift+2" = "move container to workspace \"${workspaces._2}\"";
          "${modifier}+Shift+3" = "move container to workspace \"${workspaces._3}\"";
          "${modifier}+Shift+4" = "move container to workspace \"${workspaces._4}\"";
          "${modifier}+Shift+5" = "move container to workspace \"${workspaces._5}\"";
          "${modifier}+Shift+6" = "move container to workspace \"${workspaces._6}\"";
          "${modifier}+Shift+7" = "move container to workspace \"${workspaces._7}\"";
          "${modifier}+Shift+8" = "move container to workspace \"${workspaces._8}\"";
          "${modifier}+Shift+9" = "move container to workspace \"${workspaces._9}\"";

          # Move workspaces with ctrl+mod
          "${modifier}+Ctrl+${left}" = "workspace prev";
          "${modifier}+Ctrl+${right}" = "workspace next";
          "${modifier}+Ctrl+Left" = "workspace prev";
          "${modifier}+Ctrl+Right" = "workspace next";

          # Move focused container to workspace
          "${modifier}+Ctrl+Shift+${left}" = "move container to workspace prev";
          "${modifier}+Ctrl+Shift+${right}" = "move container to workspace next";
          "${modifier}+Ctrl+Shift+Left" = "move container to workspace prev";
          "${modifier}+Ctrl+Shift+Right" = "move container to workspace next";

          # Allow loading web browser with $modifier+a
          "${modifier}+a" = "exec ${config.home.sessionVariables.BROWSER}";

          # Create a binding for the lock screen. Something close to $modifier+l
          "${modifier}+o" = "exec ${lockscreen}";

          # Create bindings for modes
          "${modifier}+r" = "mode \"resize\"";
          "${modifier}+Shift+s" = "mode \"screenshot\"";
          "${modifier}+Shift+r" = "mode \"recording\"";
        };

        input = {
          "type:keyboard" = {
            xkb_layout = "us";
            xkb_numlock = "enabled";
          };

          "type:touchpad" = {
            accel_profile = "flat";
            pointer_accel = "1";

            dwt = "enabled";
            tap = "enabled";
            natural_scroll = "disabled";
          };
        };

        startup = [
          { command = config.home.sessionVariables.BROWSER; }
          { command = user-bins.teams; }
          { command = user-bins.element; }
          # { command = user-bins.discord; }
        ];

        ### Organize startup programs
        # For how the home-manager module is written as of 2022-01-05, the
        #   workspace argument isn't quoted, technically allowing for using
        #   number name syntax, but unfortunately causing workspaces with
        #   spaces in their name to not load correctly. Workaround is quoting
        #   the workspace name.
        #
        # NOTE: See https://github.com/houstdav000/home-manager/blob/master/modules/services/window-managers/i3-sway/lib/functions.nix#L55
        #
        # TODO: Replace DiscordCanary with a wayland-compatible electron app
        #
        assigns = {
          "\"${workspaces._1}\"" = [{ app_id = "^firefox$"; }];
          "\"${workspaces._2}\"" = [{ class = "^Microsoft Teams - Preview"; }];
          "\"${workspaces._3}\"" = [{ app_id = "^Element$"; }];
          # "\"${workspaces._4}\"" = [
          #   { instance = "^discord$"; }
          #   { title = "^Discord$"; }
          # ];
        };

        bars = [{
          fonts = {
            names = [ "Fira Sans" "sans-serif" ];
            style = "Bold Semi-Condensed";
            size = 14.0;
          };
          position = "top";
          command = user-bins.waybar;
        }];

        floating = {
          border = 1;
          criteria = [
            { title = "Steam - News"; }
            { title = "Friends List"; }
            { app_id = "^pavucontrol$"; }
          ];
        };

        window = {
          border = 1;
          hideEdgeBorders = "smart";
        };

        modes =
          let
            exit-mode = "mode \"default\"";
            exitModeKeys = {
              "Return" = exit-mode;
              "Escape" = exit-mode;
            };
            outFile =
              let
                timestampFormat = "%Y-%m-%d-%H%M%S";
                timestampBash = "$(${user-bins.date} + '${timestampFormat}')";
              in
              dir: prefix: type: dir + "/" + prefix + "-" + timestampBash + "." + type;
            killRecorder = "exec ${user-bins.pkill} wf-recorder";
          in
          {
            resize =
              let
                sizes = with sizes;{
                  tiny = 5;
                  small = tiny * 2;
                  large = small * 2;
                };
                sizeMap = lib.mapAttrs (_: v: "${builtins.toString v}px") sizes;
              in
              with sizeMap; {
                # left will shrink the containers width
                # right will grow the containers width
                # up will shrink the containers height
                # down will grow the containers height
                "${left}" = "resize shrink width ${small}";
                "${down}" = "resize grow height ${small}";
                "${up}" = "resize shrink height ${small}";
                "${right}" = "resize grow width ${small}";
                "Shift+${left}" = "resize shrink width ${large}";
                "Shift+${down}" = "resize grow height ${large}";
                "Shift+${up}" = "resize shrink height ${large}";
                "Shift+${right}" = "resize grow width ${large}";

                # Ditto, with arrow keys
                "Left" = "resize shrink width ${small}";
                "Down" = "resize grow height ${small}";
                "Up" = "resize shrink height ${small}";
                "Right" = "resize grow width ${small}";
                "Shift+Left" = "resize shrink width ${large}";
                "Shift+Down" = "resize grow height ${large}";
                "Shift+Up" = "resize shrink height ${large}";
                "Shift+Right" = "resize grow width ${large}";

                ## Resize // Window Gaps // + - ##
                "minus" = "gaps inner current minus ${tiny}";
                "plus" = "gaps inner current plus ${tiny}";

                # Return to default mode
              } // exitModeKeys;

            screenshot =
              let
                screenshot-file = outFile config.xdg.userDirs.pictures "screenshot" "png";
                capture = action: area: "exec --no-startup-id ${user-bins.grimshot} --notify ${action} ${area} ${if action == "save" then screenshot-file else ""}, ${exit-mode}";
                keyMap = {
                  "f" = "screen";
                  "w" = "win";
                  "r" = "area";
                };
              in
              (lib.mapAttrs (_: capture "copy") keyMap) //
              (lib.mapAttrs' (n: v: lib.nameValuePair "Shift+${n}" (capture "save" v)) keyMap) //
              exitModeKeys;

            recording_on."Escape" = "${killRecorder}, ${exit-mode}";

            recording =
              let
                recording-mode = "mode \"recording_on\"";
                recording-file = outFile config.xdg.userDirs.videos "recording" "mp4";
                areas = {
                  win = {
                    command = "$(${user-bins.swaymsg} -t get_outputs | ${user-bins.jq} -r '.[] | select(.focused) | .name')";
                    arg = "-o";
                  };
                  area = {
                    command = "\"$(${user-bins.slurp} -d)\"";
                    arg = "-g";
                  };
                };
                audioBln = a: "--audio${if a then "" else "=0"}";
                keyMap = {
                  "w" = "win";
                  "r" = "area";
                };
                capture = audio: area: "${killRecorder} || ${user-bins.wf-recorder} ${audioBln audio} ${areas."${area}".arg} ${areas."${area}".command} -f ${recording-file}, ${recording-mode}";
              in
              (lib.mapAttrs (_: capture true) keyMap) //
              (lib.mapAttrs' (n: v: lib.nameValuePair "Shift+${n}" (capture false v)) keyMap) //
              exitModeKeys;
          };

        # Default to outputting some workspaces on other monitors if available
        workspaceOutputAssign =
          let
            mainOrSub = with screens; screenOrder [
              main
              sub
              builtin
            ];
            subOnly = with screens; screenOrder [
              sub
              builtin
            ];
          in
          [
            {
              workspace = workspaces._1;
              output = mainOrSub;
            }
            {
              workspace = workspaces._2;
              output = subOnly;
            }
            {
              workspace = workspaces._3;
              output = subOnly;
            }
            {
              workspace = workspaces._4;
              output = subOnly;
            }
            {
              workspace = workspaces._5;
              output = mainOrSub;
            }
            {
              workspace = workspaces._6;
              output = mainOrSub;
            }
            {
              workspace = workspaces._7;
              output = mainOrSub;
            }
            {
              workspace = workspaces._8;
              output = mainOrSub;
            }
            {
              workspace = workspaces._9;
              output = mainOrSub;
            }
          ];
      };

    # TODO: Change color configuration, pull out output configuration
    extraConfig = ''
      ###########################################################################
      #                                                                         #
      #                         Sway Theme Configuration                        #
      #                                                                         #
      ###########################################################################

      set $background ~/wallpaper.png
      set $backup-color #000000

      # a theme specific color map
      set $base00 #141a1b
      set $base01 #282a2b
      set $base02 #3B758C
      set $base03 #41535B
      set $base04 #43a5d5
      set $base05 #d6d6d6
      set $base06 #eeeeee
      set $base07 #ffffff
      set $base08 #Cd3f45
      set $base09 #db7b55
      set $base0A #e6cd69
      set $base0B #9fca56
      set $base0C #16a085
      set $base0D #55b5db
      set $base0E #a074c4
      set $base0F #8a553f

      # Basic color configuration using the Base16 variables for windows and borders.
      # Property Name         Border  BG      Text    Indicator Child Border
      client.focused          $base05 $base0C $base00 $base0C $base0C
      client.focused_inactive $base01 $base01 $base05 $base03 $base01
      client.unfocused        $base01 $base00 $base05 $base01 $base01
      client.urgent           $base08 $base08 $base00 $base08 $base08
      client.placeholder      $base00 $base00 $base05 $base00 $base00
      client.background       $base07

      ###########################################################################
      #                                                                         #
      #                         Sway Output Configurations                      #
      #                                                                         #
      ###########################################################################

      # Default wallpaper
      output * bg $background fill $backup-color
    '';
  };

  ### Waybar configuration
  # Configuration for a status bar provided by waybar.
  #
  # NOTE: See https://github.com/Alexays/Waybar/wiki/Configuration
  #
  xdg.configFile."waybar/config".source = (pkgs.formats.json { }).generate "config" {
    layer = "top";
    position = "top";

    # If height property would be not present, it'd be calculated dynamically
    height = 30;

    modules-left = [
      "sway/workspaces"
      "sway/mode"
    ];
    modules-center = [
      "sway/window"
    ];
    modules-right = [
      "network"
      "cpu"
      "memory"
      "battery"
      "backlight"
      "pulseaudio"
      "tray"
      "clock"
    ];

    battery = {
      interval = 30;
      states = {
        warning = 30;
        critical = 15;
      };
      format-charging = " {icon} {capacity}%"; # Icon: bolt
      format = "{icon}  {capacity}%";
      format-icons = [
        "" # Icon: battery-empty
        "" # Icon: battery-quarter
        "" # Icon: battery-half
        "" # Icon: battery-three-quarters
        "" # Icon: battery-full
      ];
      tooltip = false;
    };

    clock = {
      interval = 60;
      format = "  {:%e %b %Y %H:%M}"; # Icon: calendar-alt
      tooltip = false;
      on-click = user-bins.wlogout;
    };

    cpu = {
      interval = 5;
      format = "  {usage}%"; # Icon: microchip
      states = {
        warning = 70;
        critical = 90;
      };
    };

    memory = {
      interval = 5;
      format = "  {}%"; # Icon: memory
      states = {
        warning = 70;
        critical = 90;
      };
    };

    network = {
      interval = 5;
      format-wifi = "  {essid} ({signalStrength}%)"; # Icon: wifi
      format-ethernet = "  {ifname}: {ipaddr}/{cidr}"; # Icon: ethernet
      format-disconnected = "⚠  Disconnected";
      tooltip-format = "{ifname}: {ipaddr}";
    };

    "sway/mode" = {
      format = "<span style=\"italic\">{}</span>";
      tooltip = false;
    };

    "sway/window" = {
      format = "{}";
      max-length = 120;
    };

    "sway/workspaces" = {
      all-outputs = false;
      disable-scroll = true;
      format = "{}";
    };

    backlight = {
      format = "{icon} {percent}%";
      format-icons = [ "" "◐" "" ];
      on-scroll-down = "${user-bins.light} -U 5";
      on-scroll-up = "${user-bins.light} -A 5";
    };

    pulseaudio = {
      format = "{icon}  {volume}%";
      format-bluetooth = "{icon}  {volume}%";
      format-muted = "";
      format-icons = {
        headphones = "";
        handsfree = "";
        headset = "";
        phone = "";
        portable = "";
        car = "";
        default = [ "" "" ];
      };
      on-scroll-down = "${user-bins.pamixer} -d 2";
      on-scroll-up = "${user-bins.pamixer} -i 2";
      on-click = user-bins.pavucontrol;
    };

    tray.icon-size = 21;
  };

  ### Waybar Style configuration
  # NOTE: See https://github.com/Alexays/Waybar/wiki/Configuration
  #
  xdg.configFile."waybar/style.css".text = ''
    /*** Base Styles ***/
    * {
      border: none;
      border-radius: 0;
      min-height: 0;
      margin: 0;
      padding: 0;
      font-family: "Fira Sans", Roboto, sans-serif;
    }

    /* The whole bar */
    #waybar {
      background: @theme_base_color;
      color: @theme_text_color;
      font-family: "Fira Sans", Roboto, sans-serif;
      font-size: 14px;
    }

    /* Each module */
    #battery,
    #clock,
    #cpu,
    #custom-keyboard-layout,
    #memory,
    #mode,
    #network,
    #pulseaudio,
    #tray {
      font-family: "Fira Sans", Roboto, sans-serif;
      padding-left: 10px;
      padding-right: 10px;
    }

    /*** Module Styles ***/
    #battery {
      animation-timing-function: linear;
      animation-iteration-count: infinite;
      animation-direction: alternate;
    }

    #battery.warning {
      color: @warning_color;
    }

    #battery.critical {
      color: @error_color;
    }

    #clock {
      font-weight: bold;
    }

    #cpu {
      /* No styles */
    }

    #cpu.warning {
      color: @warning_color;
    }

    #cpu.critical {
      color: @error_color;
    }

    #memory.warning {
      color: @warning_color;
    }

    #memory.critical {
      color: @error_color;
    }

    #mode {
      background: @theme_focused_fg_color;
    }

    #network {
      /* No styles */
    }

    #network.disconnected {
      color: @error_color;
    }

    #pulseaudio {
      /* No styles */
    }

    #pulseaudio.muted {
      /* No styles */
    }

    #tray {
      /* No styles */
    }

    #window {
      font-weight: bold;
      font-family: "Fira Sans", Roboto, sans-serif;
    }

    #workspaces button {
      border-top: 2px solid transparent;
      /* To compensate for the top border and still have vertical centering */
      padding-bottom: 2px;
      padding-left: 10px;
      padding-right: 10px;
      color: @theme_unfocused_text_color;
    }

    #workspaces button.focused {
      border-color: @theme_selected_bg_color;
      color: @theme_selected_fg_color;
      background-color: @theme_selected_bg_color;
    }

    #workspaces button.urgent {
      border-color: @warning_color;
      color: @warning_color;
    }
  '';

  ### Power Menu
  # Provide a power/logout menu.
  #
  # TODO: Make into a home-manager module?
  #
  xdg.configFile."wlogout/layout".text = ''
    {
      "label": "lock",
      "action": "${lockscreen}",
      "text" : "Lock",
      "keybind": "1"
    }
    {
      "label": "hibernate",
      "action": "${user-bins.systemctl} hibernate",
      "text": "Hibernate",
      "keybind": "h"
    }
    {
      "label": "logout",
      "action": "${user-bins.loginctl} terminate-user $USER",
      "text": "Logout",
      "keybind": "e"
    }
    {
      "label" : "shutdown",
      "action" : "${user-bins.systemctl} poweroff",
      "text" : "Shutdown",
      "keybind" : "s"
    }
    {
      "label" : "suspend",
      "action" : "${user-bins.systemctl} suspend",
      "text" : "Suspend",
      "keybind" : "u"
    }
    {
      "label" : "reboot",
      "action" : "${user-bins.systemctl} reboot",
      "text" : "Reboot",
      "keybind" : "r"
    }
  '';

  programs.rofi = {
    enable = true;
    package = pkgs.nixos-unstable.rofi-wayland;
    terminal = config.home.sessionVariables.TERMINAL;
    font = "Fira Sans 14";
    theme = "android_notification";
    extraConfig.modi = "drun,run";
  };

  ### Kanshi Dynamic Output Daemon
  # Configure screens dynamically, since my current workstation is a laptop I
  #   may or may not have docked at the time.
  #
  services.kanshi = {
    enable = true;

    profiles = {
      undocked.outputs = [{
        criteria = screens.builtin;
        status = "enable";
      }];
      docked.outputs = [
        {
          criteria = screens.builtin;
          status = "disable";
        }
        {
          criteria = screens.main;
          status = "enable";
          position = "0,0";
        }
        {
          criteria = screens.sub;
          status = "enable";
          position = "1920,0";
        }
      ];
    };
  };

  # Have kanshi restart to ensure
  home.activation.restart-kanshi = lib.hm.dag.entryAfter [ "reloadSystemd" ] ''
    $DRY_RUN_CMD ${user-bins.systemctl} restart $VERBOSE_ARG --user kanshi.service
  '';

  ### Mako Notification Daemon
  # Configure a notification daemon for Sway, providing
  #   `org.freedesktop.Notifications`.
  #
  # TODO: Add systemd service to home-manager module?
  #
  programs.mako = {
    enable = true;

    defaultTimeout = 15 * 1000;
    iconPath = lib.concatStringsSep ":" [
      "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark"
      "${pkgs.papirus-icon-theme}/share/icons/Papirus"
      "${pkgs.hicolor-icon-theme}/share/icons/hicolor"
    ];
  };

  systemd.user.services.mako =
    let
      configFile = "${config.xdg.configHome}/mako/config";
    in
    {
      Unit = {
        Description = "mako notification daemon for Sway";
        Documentation = "man:mako(1)";
        PartOf = [ "graphical-session.target" ];
        ConditionPathExists = configFile;
      };

      Install.WantedBy = [ "graphical-session.target" ];

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.mako}/bin/mako --config ${configFile}";
        ExecStartPost =
          if
            config.services.mpdris2.enable
          then
            "${pkgs.systemd}/bin/systemctl --user -- restart mpdris2.service"
          else
            "";
        BusName = "org.freedesktop.Notifications";
      };
    };

  ### Idle Daemon
  # Need an idle daemon to lock the system and turn off the screen if I step
  #   away.
  #
  # services.swayidle = {
  #   enable = true;

  #   timeouts = [
  #     {
  #       timeout = 900;
  #       command = "exec ${lockscreen}";
  #     }
  #     {
  #       timeout = 960;
  #       command = "${user-bins.swaymsg} \"output * dpms off\"";
  #       resumeCommand = "${user-bins.swaymsg} \"output * dpms on\"";
  #     }
  #   ];
  #   events = [
  #     {
  #       event = "before-sleep";
  #       command = "${user-bins.playerctl} pause";
  #     }
  #     {
  #       event = "before-sleep";
  #       command = "exec ${lockscreen}";
  #     }
  #   ];
  # };
  systemd.user.services.swayidle =
    let
      args = builtins.concatStringsSep " " [
        "timeout 900 \"exec ${lockscreen}\""
        "timeout 960 \"${user-bins.swaymsg} \\\"output * dpms off \\\"\""
        "resume \"${user-bins.swaymsg} \\\"output * dpms on \\\"\""

      ];
    in
    {
      Unit = {
        Description = "Idle manager for Wayland";
        Documentation = "man:swayidle(1)";
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.swayidle}/bin/swayidle -w ${args}";
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
}
