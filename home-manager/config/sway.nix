{ config, pkgs, lib, ... }:
let
  palletes.nord = {
    base00 = "#2E3440";
    base01 = "#3B4252";
    base02 = "#434C5E";
    base03 = "#4C566A";
    base04 = "#D8DEE9";
    base05 = "#E5E9F0";
    base06 = "#ECEFF4";
    base07 = "#8FBCBB";
    base08 = "#88C0D0";
    base09 = "#81A1C1";
    base0A = "#5E81AC";
    base0B = "#BF616A";
    base0C = "#D08770";
    base0D = "#EBCB8B";
    base0E = "#A3BE8C";
    base0F = "#B48EAD";
  };

  toScreen = { name, id ? null, outputString ? null, xPixels, yPixels, refreshRate, scale ? 1.0 }:
    assert builtins.isString name;
    assert id == null || builtins.isString id;
    assert outputString == null || builtins.isString outputString;
    assert builtins.isInt xPixels;
    assert builtins.isInt yPixels;
    assert builtins.isFloat refreshRate || builtins.isInt refreshRate;
    assert builtins.isFloat scale;
    assert (id != null && outputString == null) || (id == null && outputString != null);
    let
      resolution = "${xPixels}x${yPixels}";
      modeString = "${resolution} @ ${refreshRate} Hz";
      criteria =
        if
          id != null
        then
          id
        else
          outputString;
      xPixelsOut = builtins.ceil (xPixels * (1 / scale));
      yPixelsOut = builtins.ceil (yPixels * (1 / scale));
    in
    {
      inherit criteria modeString name refreshRate resolution scale xPixels xPixelsOut yPixels yPixelsOut;
    };

  screens = {
    builtin = toScreen {
      name = "Built-in display";
      id = "eDP-1";
      xPixels = 2256;
      yPixels = 1504;
      refreshRate = 59.999;
    };
    homeDockCenter = toScreen {
      name = "ASUS High Refresh-Rate Monitor";
      outputString = "Unknown VG28UQL1A 0x00000101";
      scale = 1.75;
      xPixels = 3840;
      yPixels = 2160;
      refreshRate = 30; # High refresh rate/resolution, but can't run it at such
    };
    homeDockLeft = toScreen {
      name = "ASUS Low Refresh-Rate Monitor";
      outputString = "Unknown VA279 N2LMQS025509";
      xPixels = 1920;
      yPixels = 1080;
      refreshRate = 60;
    };
    homeDockRight = toScreen {
      name = "ViewSonic 4:3 Monitor";
      outputString = "ViewSonic Corporation VP211b A22050300003";
      xPixels = 1600;
      yPixels = 1200;
      refreshRate = 60;
    };
    homeDockRightFallback = toScreen {
      name = "ViewSonic 4:3 Monitor Fallback";
      outputString = "<Unknown> <Unknown> "; # The displayport to DVI adapter likes to act up
      xPixels = 1024;
      yPixels = 768;
      refreshRate = 60.004;
    };

    # Functions
    screenOrder = list: lib.escapeShellArgs (builtins.map (x: assert builtins.isAttrs x; x."criteria") list);
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
    teams = "${pkgs.nixpkgs-unstable.teams}/bin/teams";
    waybar = "${pkgs.waybar}/bin/waybar";
    wf-recorder = "${pkgs.wf-recorder}/bin/wf-recorder";
    wlogout = "${pkgs.wlogout}/bin/wlogout";
    xargs = "${pkgs.findutils}/bin/xargs";
  };

  lockscreen = lib.concatStringsSep " " [
    "${user-bins.swaylock}"
    "--daemonize"
    "--show-failed-attempts"
    "--image ${config.home.homeDirectory}/lockscreen.jpg"
    "--clock"
    "--indicator"
    #"--effect-blur 7x5"
    "--effect-vignette 0.5:0.5"
    "--fade-in 0.2"
  ];

  ### Workspace Configuration
  # Set a name for workspaces
  #
  workspaces = {
    _1 = "1:   Web";
    _2 = "2:   Teams";
    _3 = "3:   Matrix";
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
        up = "k";
        down = "j";

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
          "\"${workspaces._3}\"" = [{ class = "^Element$"; } { instance = "^element$"; } { title = "^Element"; }];
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
            { app_id = "firefox"; title = "About Mozilla Firefox"; }
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
            center = with screens; screenOrder [
              homeDockCenter
              homeDockLeft
              homeDockRight
              homeDockRightFallback
              builtin
            ];
            left = with screens; screenOrder [
              homeDockLeft
              homeDockCenter
              homeDockRight
              homeDockRightFallback
              builtin
            ];
            right = with screens; screenOrder [
              homeDockRight
              homeDockRightFallback
              homeDockCenter
              homeDockLeft
              builtin
            ];
          in
          [
            {
              workspace = workspaces._1;
              output = left;
            }
            {
              workspace = workspaces._2;
              output = right;
            }
            {
              workspace = workspaces._3;
              output = right;
            }
            {
              workspace = workspaces._4;
              output = right;
            }
            {
              workspace = workspaces._5;
              output = center;
            }
            {
              workspace = workspaces._6;
              output = center;
            }
            {
              workspace = workspaces._7;
              output = center;
            }
            {
              workspace = workspaces._8;
              output = center;
            }
            {
              workspace = workspaces._9;
              output = center;
            }
          ];

        colors = with palletes.nord; {
          background = base07;
          focused = {
            border = base05;
            background = base0C;
            text = base00;
            indicator = base0C;
            childBorder = base0C;
          };

          focusedInactive = {
            border = base01;
            background = base01;
            text = base05;
            indicator = base03;
            childBorder = base01;
          };

          unfocused = {
            border = base01;
            background = base00;
            text = base05;
            indicator = base01;
            childBorder = base01;
          };

          urgent = {
            border = base08;
            background = base08;
            text = base00;
            indicator = base08;
            childBorder = base08;
          };

          placeholder = {
            border = base00;
            background = base00;
            text = base05;
            indicator = base00;
            childBorder = base00;
          };
        };
        output."*".bg = "~/wallpaper.png fill #000000";
      };
    extraConfig = ''
      workspace "${workspaces._9}"
      workspace "${workspaces._8}"
      workspace "${workspaces._7}"
      workspace "${workspaces._6}"
      workspace "${workspaces._5}"
      workspace "${workspaces._4}"
      workspace "${workspaces._3}"
      workspace "${workspaces._2}"
      workspace "${workspaces._1}"
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
      "keybind": "i"
    }
    {
      "label" : "shutdown",
      "action" : "${user-bins.systemctl} poweroff",
      "text" : "Shutdown",
      "keybind" : "u"
    }
    {
      "label" : "suspend",
      "action" : "${user-bins.systemctl} suspend",
      "text" : "Suspend",
      "keybind" : "s"
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

    profiles = with screens; {
      undocked.outputs = [{
        inherit (screens.builtin) criteria;
        status = "enable";
      }];

      singleMonitor.outputs = [
        {
          inherit (screens.builtin) criteria;
          status = "enable";
          position = "0,0";
        }
        {
          criteria = "*";
          status = "enable";
          position = "${builtins.toString screens.builtin.xPixelsOut},0";
        }
      ];

      homeDockedFull.outputs = [
        {
          inherit (screens.builtin) criteria;
          status = "disable";
        }
        {
          inherit (screens.homeDockLeft) criteria;
          status = "enable";
          position = "0,0";
        }
        {
          inherit (screens.homeDockCenter) criteria scale;
          status = "enable";
          position = "${builtins.toString screens.homeDockLeft.xPixelsOut},0";
        }
        {
          inherit (screens.homeDockRight) criteria;
          status = "enable";
          position = "${builtins.toString (screens.homeDockLeft.xPixelsOut + screens.homeDockCenter.xPixelsOut)},0";
        }
      ];

      homeDockedFullFallback.outputs = [
        {
          inherit (screens.builtin) criteria;
          status = "disable";
        }
        {
          inherit (screens.homeDockLeft) criteria;
          status = "enable";
          position = "0,0";
        }
        {
          inherit (screens.homeDockCenter) criteria scale;
          status = "enable";
          position = "${builtins.toString screens.homeDockLeft.xPixelsOut},0";
        }
        {
          inherit (screens.homeDockRightFallback) criteria;
          status = "enable";
          position = "${builtins.toString (screens.homeDockLeft.xPixelsOut + screens.homeDockCenter.xPixelsOut)},0";
        }
      ];

      homeDockedPartialNoLeft.outputs = [
        {
          inherit (screens.builtin) criteria;
          status = "disable";
        }
        {
          inherit (screens.homeDockCenter) criteria scale;
          status = "enable";
          position = "0,0";
        }
        {
          inherit (screens.homeDockRight) criteria;
          status = "enable";
          position = "${builtins.toString screens.homeDockCenter.xPixelsOut},0";
        }
      ];

      homeDockedPartialNoCenter.outputs = [
        {
          inherit (screens.builtin) criteria;
          status = "disable";
        }
        {
          inherit (screens.homeDockLeft) criteria;
          status = "enable";
          position = "0,0";
        }
        {
          inherit (screens.homeDockRight) criteria;
          status = "enable";
          position = "${builtins.toString screens.homeDockLeft.xPixelsOut},0";
        }
      ];

      homeDockedPartialNoRight.outputs = [
        {
          inherit (screens.builtin) criteria;
          status = "disable";
        }
        {
          inherit (screens.homeDockLeft) criteria;
          status = "enable";
          position = "0,0";
        }
        {
          inherit (screens.homeDockCenter) criteria scale;
          status = "enable";
          position = "${builtins.toString screens.homeDockLeft.xPixelsOut},0";
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
