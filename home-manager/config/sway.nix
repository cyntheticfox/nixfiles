{ config, pkgs, lib, ... }:
let
  screens = {
    builtin = "eDP-1";
    main = "Samsung Electric Company SMS27A350H 0x00007F36";
    sub = "ViewSonic Corporation VP211b A22050300003";
  };
  user-bins = {
    grimshot = "${pkgs.sway-contrib.grimshot}/bin/grimshot";
    jq = "${pkgs.jq}/bin/jq";
    kitty = "${pkgs.kitty}/bin/kitty";
    light = "${pkgs.light}/bin/light";
    loginctl = "${pkgs.systemd}/bin/loginctl";
    mako = "${pkgs.mako}/bin/mako";
    pamixer = "${pkgs.pamixer}/bin/pamixer";
    pkill = "${pkgs.procps}/bin/pkill";
    playerctl = "${pkgs.playerctl}/bin/playerctl";
    qutebrowser = "${pkgs.qutebrowser}/bin/qutebrowser";
    rofi = "${pkgs.rofi-wayland}/bin/rofi";
    slurp = "${pkgs.slurp}/bin/slurp";
    swayidle = "${pkgs.swayidle}/bin/swayidle";
    swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
    swaymsg = "${pkgs.sway}/bin/swaymsg";
    systemctl = "${pkgs.systemd}/bin/systemd";
    waybar = "${pkgs.waybar}/bin/waybar";
    wf-recorder = "${pkgs.wf-recorder}/bin/wf-recorder";
    wlogout = "${pkgs.wlogout}/bin/wlogout";
    xargs = "${pkgs.findutils}/bin/xargs";
  };

  ### Lockscreen Configuration
  # This will configure how your screen looks when you lock it, setting the
  #   colors, effects, indicators, and fade.
  #
  lockscreen = lib.concatStringsSep " " [
    "${user-bins.swaylock}"
    "--daemonize"
    "--show-failed-attempts"
    "--screenshots"
    "--clock"
    "--indicator"
    "--effect-blur 7x5"
    "--effect-vignette 0.5:0.5"
    "--fade-in 0.2"
  ];

  ### Idle Configuration
  # This will lock your screen after 15 minutes of inactivity, then turn off
  #   your displays after another minute, and turn your screens back on when
  #   resumed. It will also lock your screen before your computer goes to sleep.
  #
  idle = lib.concatStringsSep " " [
    "${user-bins.swayidle} -w "
    "timeout 900 'exec ${lockscreen}' "
    "timeout 960 '${user-bins.swaymsg} \"output * dpms off\"' "
    "resume '${user-bins.swaymsg} \"output * dpms on\"' "
    "before-sleep '${user-bins.playerctl} pause' "
    "before-sleep 'exec ${lockscreen}'"
  ];

  ### Notifications Configuration
  # Sets a default timeout of 15 seconds
  #
  notifications = lib.concatStringsSep " " [
    "${user-bins.mako}"
    "--default-timeout 15000"
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
in {
  imports = [ ./base-desktop.nix ];

  services.playerctld.enable = true;

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    systemdIntegration = true;
    config =
    let
      # Use start/logo key for modifiers
      modifier = "Mod4";

      # Use vim-like keybindings
      left = "h";
      right = "l";
      up = "j";
      down = "k";

      # Your preferred application launcher
      # Note: pass the final command to swaymsg so that the resulting window can be opened
      #   on the original workspace that the command was run on.
      appmenu = "${user-bins.rofi} -show drun | ${user-bins.xargs} ${user-bins.swaymsg} exec --";
      menu = "${user-bins.rofi} -show run | ${user-bins.xargs} ${user-bins.swaymsg} exec --";

      # Shutdown command
      shutdown = "${user-bins.wlogout} --buttons-per-row 3";
    in {
      inherit modifier left right up down;

      # Set the terminal
      terminal = user-bins.kitty;

      # Use some of the default keybindings
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
        "${modifier}+a" = "exec ${user-bins.qutebrowser}";

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
        { command = "${idle}"; }
        { command = "${notifications}"; }
        { command = "${user-bins.qutebrowser}"; }
        { command = "${pkgs.teams}/bin/teams"; }
        { command = "${pkgs.element-desktop-wayland}/bin/element-desktop"; }
      ];

      bars = [{
        fonts = {
          names = [ "FontAwesome5Free" "Noto Sans" "Roboto" "sans-serif" ];
          style = "Bold Semi-Condensed";
          size = 11.0;
        };
        position = "top";
        command = "${user-bins.waybar}";
      }];

      floating = {
        border = 1;
        criteria = [
          { "title" = "Steam - News"; }
          { "title" = "Friends List"; }
          { "class" = "Pavucontrol"; }
        ];
      };

      window = {
        border = 1;
        hideEdgeBorders = "smart";
      };

      modes = {
        resize =
        let
          small = "10px";
          large = "20px";
        in {
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
          "minus" = "gaps inner current minus 5px";
          "plus" = "gaps inner current plus 5px";

          # Return to default mode
          "Return" = "mode \"default\"";
          "Escape" = "mode \"default\"";
        };

        screenshot =
        let
          exit-mode = "mode \"default\"";
          screenshot-file = "${config.xdg.userDirs.pictures}/screenshot-$(${pkgs.coreutils}/bin/date +'%Y-%m-%d-%H%M%S').png";
        in {
          # Fullscreen screenshot
          "f" =  "exec --no-startup-id ${user-bins.grimshot} --notify copy screen, ${exit-mode}";
          "Shift+f" = "exec --no-startup-id ${user-bins.grimshot} --notify save screen ${screenshot-file}, ${exit-mode}";

          # Window screenshot
          "w" = "exec --no-startup-id ${user-bins.grimshot} --notify copy win, ${exit-mode}";
          "Shift+w" = "exec --no-startup-id ${user-bins.grimshot} --notify save win ${screenshot-file}, ${exit-mode}";

          # Region screenshot
          "r" = "exec --no-startup-id ${user-bins.grimshot} --notify copy area, ${exit-mode}";
          "Shift+r" = "exec --no-startup-id ${user-bins.grimshot} --notify save area ${screenshot-file}, ${exit-mode}";

          # Return to default mode.
          "Escape"  = exit-mode;
          "Return" =  exit-mode;
        };

        recording_on = {
          "Escape" = "exec ${user-bins.pkill} wf-recorder, mode \"default\"";
        };

        recording =
        let
          exit-mode = "mode \"default\"";
          recording-mode = "mode \"recording_on\"";
          recording-file = "${config.xdg.userDirs.videos}/recording-$(${pkgs.coreutils}/bin/date +'%Y-%m-%d-%H%M%S').mp4";
          subcommand = "${user-bins.swaymsg} -t get_outputs | ${user-bins.jq} -r '.[] | select(.focused) | .name'";
        in {
          # Window recording
          "w" = "exec ${user-bins.pkill} wf-recorder || ${user-bins.wf-recorder} --audio=0 -o $(${subcommand}) -f ${recording-file}, ${recording-mode}";
          "Shift+w" = "exec ${user-bins.pkill} wf-recorder || ${user-bins.wf-recorder} --audio -o $(${subcommand}) -f ${recording-file}, ${recording-mode}";

          # Region recording w/ Slurp
          "r" = "exec ${user-bins.pkill} wf-recorder || ${user-bins.wf-recorder} --audio=0 -g \"$(${user-bins.slurp} -d)\" -f ${recording-file}, ${recording-mode}";
          "Shift+r" = "exec ${user-bins.pkill} wf-recorder || ${user-bins.wf-recorder} --audio -g \"$(${user-bins.slurp} -d)\" -f ${recording-file}, ${recording-mode}";

          # Return to default mode.
          "Escape" = exit-mode;
          "Return" = exit-mode;
        };
      };
    };

    extraConfig = ''
      # Default to outputting some workspaces on other monitors if available
      workspace "${workspaces._1}" output "${screens.main}" "${screens.sub}" "${screens.builtin}"
      workspace "${workspaces._2}" output "${screens.sub}" "${screens.builtin}"
      workspace "${workspaces._3}" output "${screens.sub}" "${screens.builtin}"
      workspace "${workspaces._4}" output "${screens.sub}" "${screens.builtin}"
      workspace "${workspaces._5}" output "${screens.main}" "${screens.sub}" "${screens.builtin}"
      workspace "${workspaces._6}" output "${screens.main}" "${screens.sub}" "${screens.builtin}"
      workspace "${workspaces._7}" output "${screens.main}" "${screens.sub}" "${screens.builtin}"
      workspace "${workspaces._8}" output "${screens.main}" "${screens.sub}" "${screens.builtin}"
      workspace "${workspaces._9}" output "${screens.main}" "${screens.sub}" "${screens.builtin}"

      # https://github.com/Alexays/Waybar/issues/1093#issuecomment-841846291
      # exec systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK
      # exec hash dbus-update-activation-environment 2>/dev/null && \
      #     dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK

      ###########################################################################
      #                                                                         #
      #                         Sway Theme Configuration                        #
      #                                                                         #
      ###########################################################################

      set $background ~/wallpaper.png
      set $backup-color #000000
      set $gtk-theme Matcha-dark-sea
      set $icon-theme Papirus-Dark-Maia
      set $cursor-theme xcursor-breeze
      set $gui-font Noto Sans 11
      set $term-font TerminessTTF Nerd Font Mono 14
      set $kvantum-theme Matchama-Dark

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

      set $transparent-background-color rgba(20, 26, 27, 0.9)

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

  # Waybar configuration
  #
  # Ref: https://github.com/Alexays/Waybar/wiki/Configuration
  xdg.configFile."waybar/config".text = ''
    {
      // -------------------------------------------------------------------------
      // Global configuration
      // -------------------------------------------------------------------------

      "layer": "top",

      "position": "top",

      // If height property would be not present, it'd be calculated dynamically
      "height": 30,

      "modules-left": [
        "sway/workspaces",
        "sway/mode"
      ],
      "modules-center": [
        "sway/window"
      ],
      "modules-right": [
        "network",
        "cpu",
        "memory",
        "battery",
        "backlight",
        "pulseaudio",
        "tray",
        "clock"
      ],


      // -------------------------------------------------------------------------
      // Modules
      // -------------------------------------------------------------------------

      "battery": {
        "interval": 30,
        "states": {
          "warning": 30,
          "critical": 15
        },
        "format-charging": "  {icon}  {capacity}%", // Icon: bolt
        "format": "{icon}  {capacity}%",
        "format-icons": [
          "", // Icon: battery-empty
          "", // Icon: battery-quarter
          "", // Icon: battery-half
          "", // Icon: battery-three-quarters
          ""  // Icon: battery-full
        ],
        "tooltip": false,
      },

      "clock": {
        "interval": 60,
        "format": "  {:%e %b %Y %H:%M}", // Icon: calendar-alt
        "tooltip": false,
        "on-click": "${user-bins.wlogout}"
      },

      "cpu": {
        "interval": 5,
        "format": "  {usage}%", // Icon: microchip
        "states": {
          "warning": 70,
          "critical": 90
        }
      },

      "memory": {
        "interval": 5,
        "format": "  {}%", // Icon: memory
        "states": {
          "warning": 70,
          "critical": 90
        }
      },

      "network": {
        "interval": 5,
        "format-wifi": "  {essid} ({signalStrength}%)", // Icon: wifi
        "format-ethernet": "  {ifname}: {ipaddr}/{cidr}", // Icon: ethernet
        "format-disconnected": "⚠  Disconnected",
        "tooltip-format": "{ifname}: {ipaddr}",
      },

      "sway/mode": {
        "format": "<span style=\"italic\">{}</span>",
        "tooltip": false
      },

      "sway/window": {
        "format": "{}",
        "max-length": 120
      },

      "sway/workspaces": {
        "all-outputs": false,
        "disable-scroll": true,
        "format": "{}"
      },

      "backlight": {
        "format": "{icon} {percent}%",
        "format-icons": ["", "◐", ""],
        "on-scroll-down": "${user-bins.light} -U 5",
        "on-scroll-up": "${user-bins.light} -A 5"
      },

      "pulseaudio": {
        //"scroll-step": 1,
        "format": "{icon}  {volume}%",
        "format-bluetooth": "{icon}  {volume}%",
        "format-muted": "",
        "format-icons": {
          "headphones": "",
          "handsfree": "",
          "headset": "",
          "phone": "",
          "portable": "",
          "car": "",
          "default": ["", ""]
        },
        "on-scroll-down": "${user-bins.pamixer} -d 2",
        "on-scroll-up": "${user-bins.pamixer} -i 2",
        "on-click": "pavucontrol"

      },

      "tray": {
        "icon-size": 21
      }
    }
  '';

  # Waybar Style configuration
  #
  # Ref: https://github.com/Alexays/Waybar/wiki/Configuration
  xdg.configFile."waybar/style.css".text = ''
    /* -----------------------------------------------------------------------------
     * Keyframes
     * -----------------------------------------------------------------------------
     */

    @keyframes blink-warning {
      70% {
        color: #eeeeee;
      }

      to {
        color: #eeeeee;
        background-color: #db7b55;
      }
    }

    @keyframes blink-critical {
      70% {
        color: #eeeeee;
      }

      to {
        color: #eeeeee;
        background-color: #Cd3f45;
      }
    }


    /* -----------------------------------------------------------------------------
     * Base styles
     * -----------------------------------------------------------------------------
     */

    /* Reset all styles */
    * {
      border: none;
      border-radius: 0;
      min-height: 0;
      margin: 0;
      padding: 0;
      font-family: "Noto Sans", Roboto, sans-serif;
    }

    /* The whole bar */
    #waybar {
      background: #141a1b;
      color: #eeeeee;
      font-family: "Noto Sans", Roboto, sans-serif;
      font-size: 13px;
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
      font-family: "FontAwesome 5 Free Solid", "Noto Sans", Roboto, sans-serif;
      padding-left: 10px;
      padding-right: 10px;
    }

    /* -----------------------------------------------------------------------------
     * Module styles
     * -----------------------------------------------------------------------------
     */

    #battery {
      animation-timing-function: linear;
      animation-iteration-count: infinite;
      animation-direction: alternate;
    }

    #battery.warning {
      color: #db7b55;
    }

    #battery.critical {
      color: #Cd3f45;
    }

    #battery.warning.discharging {
      animation-name: blink-warning;
      animation-duration: 3s;
    }

    #battery.critical.discharging {
      animation-name: blink-critical;
      animation-duration: 2s;
    }

    #clock {
      font-weight: bold;
    }

    #cpu {
      /* No styles */
    }

    #cpu.warning {
      color: #db7b55;
    }

    #cpu.critical {
      color: #Cd3f45;
    }

    #memory {
      animation-timing-function: linear;
      animation-iteration-count: infinite;
      animation-direction: alternate;
    }

    #memory.warning {
      color: #db7b55;
    }

    #memory.critical {
      color: #Cd3f45;
      animation-name: blink-critical;
      animation-duration: 2s;
    }

    #mode {
      background: #141a1b;
    }

    #network {
      /* No styles */
    }

    #network.disconnected {
      color: #db7b55;
    }

    #pulseaudio {
      /* No styles */
    }

    #pulseaudio.muted {
      /* No styles */
    }

    #custom-spotify {
      color: #16a085;
    }

    #tray {
      /* No styles */
    }

    #window {
      font-weight: bold;
      font-family: "Noto Sans", Roboto, sans-serif;
    }

    #workspaces button {
      border-top: 2px solid transparent;
      /* To compensate for the top border and still have vertical centering */
      padding-bottom: 2px;
      padding-left: 10px;
      padding-right: 10px;
      color: #d6d6d6;
    }

    #workspaces button.focused {
      border-color: #16a085;
      color: #eeeeee;
      background-color: #16a085;
    }

    #workspaces button.urgent {
      border-color: #Cd3f45;
      color: #Cd3f45;
    }
  '';

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
    package = pkgs.rofi-wayland;
    terminal = user-bins.kitty;
    font = "Noto Sans 12";
    theme = "android_notification";
    extraConfig.modi = "drun,run";
  };

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
          criteria = screens.sub;
          status = "enable";
        }
        {
          criteria = screens.main;
          status = "enable";
        }
      ];
    };
  };
}
