{ config, pkgs, lib, ... }:
let
  user-bins = {
    kitty = "${pkgs.kitty}/bin/kitty";
    qutebrowser = "${pkgs.qutebrowser}/bin/qutebrowser";
    pamixer = "${pkgs.pamixer}/bin/pamixer";
    playerctl = "${pkgs.playerctl}/bin/playerctl";
    swayidle = "${pkgs.swayidle}/bin/swayidle";
    swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
    swaymsg = "${pkgs.sway}/bin/swaymsg";
    wofi = "${pkgs.wofi}/bin/wofi";
    xargs = "${pkgs.findutils}/bin/xargs";
  };
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

  ### Idle configuration
  # This will lock your screen after 15 minutes of inactivity, then turn off
  #   your displays after another minute, and turn your screens back on when
  #   resumed. It will also lock your screen before your computer goes to sleep.
  #
  idle = lib.concatStringsSep " " [
    "$idle ${user-bins.swayidle} -w "
    "timeout 900 'exec ${lockscreen}' "
    "timeout 960 '${user-bins.swaymsg} \"output * dpms off\"' "
    "resume '${user-bins.swaymsg} \"output * dpms on\"' "
    "before-sleep '${user-bins.playerctl} pause' "
    "before-sleep 'exec ${lockscreen}'"
  ];
in {
  imports = [ ./base-desktop.nix ];

  services.playerctld.enable = true;

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    systemdIntegration = true;
    config = null;
    extraConfig = ''
      ###########################################################################
      #                                                                         #
      #                         Sway Variable Definitions                       #
      #                                                                         #
      ###########################################################################

      ### Variables
      #
      # Logo key. Use Mod1 for Alt.
      # * change modifier key from Alt to Win/Pine-Key: set $mod Mod4
      set $mod Mod4

      # Home row direction keys, like vim
      set $left h
      set $down j
      set $up k
      set $right l

      # Your preferred terminal emulator
      set $term ${user-bins.kitty}

      # Your preferred web browser
      set $web ${user-bins.qutebrowser}

      # Your preferred application launcher
      # Note: pass the final command to swaymsg so that the resulting window can be opened
      #   on the original workspace that the command was run on.
      set $appmenu ${user-bins.wofi} --show drun | ${user-bins.xargs} ${user-bins.swaymsg} exec --
      set $menu ${user-bins.wofi} --show run --exec-search | ${user-bins.xargs} ${user-bins.swaymsg} exec --

      set $notifications mako --default-timeout 15000

      # statusbar command
      set $statusbar waybar

      # shutdown command
      set $shutdown wlogout --buttons-per-row 3

      ###########################################################################
      #                                                                         #
      #                         Sway Input Configurations                       #
      #                                                                         #
      ###########################################################################

      # Default keyboard configuration
      input type:keyboard {
        xkb_layout "us"
        xkb_numlock enabled
      }

      # Touchpad configuration (if using a laptop)
      input type:touchpad {
        accel_profile flat
        pointer_accel 1

        dwt enabled
        tap enabled
        natural_scroll disabled
      }

      ###########################################################################
      #                                                                         #
      #                         Sway Startup Configurations                     #
      #                                                                         #
      ###########################################################################

      # Enable the idle daemon
      exec ${idle}

      # Autostart background apps
      exec $notifications

      # Run if-exists
      exec_always {
          '[ -x "$(command -v workstyle)" ] && pkill workstyle; workstyle &> ~/tmp/workstyle.log'
      }

      # https://github.com/Alexays/Waybar/issues/1093#issuecomment-841846291
      exec systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK
      exec hash dbus-update-activation-environment 2>/dev/null && \
          dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK

      ###########################################################################
      #                                                                         #
      #                         Sway Mode Configurations                        #
      #                                                                         #
      ###########################################################################

      #\                               /#
      # |  Default Mode Configuration | #
      #/                               \#

      ### Key bindings
      #
      # Basics:
      #
      # Start a terminal
      bindsym $mod+Return exec $term

      # Kill focused window
      bindsym $mod+Shift+q kill

      # Start your launcher
      bindsym $mod+d exec $appmenu
      bindsym $mod+Shift+d exec $menu
      bindsym $mod+Ctrl+d exec $selwin
      bindsym $mod+question exec $help

      # Drag floating windows by holding down $mod and left mouse button.
      # Resize them with right mouse button + $mod.
      # Despite the name, also works for non-floating windows.
      # Change normal to inverse to use left mouse button for resizing and right
      # mouse button for dragging.
      floating_modifier $mod normal

      # Reload the configuration file
      bindsym $mod+Shift+c reload

      # Exit sway (logs you out of your Wayland session)
      bindsym $mod+Shift+e exec $shutdown

      # Media key bindings
      bindsym XF86AudioMute exec ${user-bins.pamixer} -t
      bindsym XF86AudioNext exec ${user-bins.playerctl} next
      bindsym XF86AudioPlay exec ${user-bins.playerctl} play-pause
      bindsym XF86AudioPrev exec ${user-bins.playerctl} previous
      bindsym XF86AudioLowerVolume exec ${user-bins.pamixer} -d 2
      bindsym XF86AudioRaiseVolume exec ${user-bins.pamixer} -i 2
      bindsym XF86AudioStop exec ${user-bins.playerctl} stop


      # Screen brightness bindings
      bindsym XF86MonBrightnessDown exec light -U 5
      bindsym XF86MonBrightnessUp exec light -A 5

      # capture PowerOff key
      bindsym XF86PowerOff exec $shutdown

      #
      # Moving around:
      #
      # Move your focus around
      bindsym $mod+$left focus left
      bindsym $mod+$down focus down
      bindsym $mod+$up focus up
      bindsym $mod+$right focus right
      # Or use $mod+[up|down|left|right]
      bindsym $mod+Left focus left
      bindsym $mod+Down focus down
      bindsym $mod+Up focus up
      bindsym $mod+Right focus right

      # Move the focused window with the same, but add Shift
      bindsym $mod+Shift+$left move left
      bindsym $mod+Shift+$down move down
      bindsym $mod+Shift+$up move up
      bindsym $mod+Shift+$right move right
      # Ditto, with arrow keys
      bindsym $mod+Shift+Left move left
      bindsym $mod+Shift+Down move down
      bindsym $mod+Shift+Up move up
      bindsym $mod+Shift+Right move right

      #
      # Workspaces:
      #
      # Switch to workspace
      bindsym $mod+1 workspace number 1
      bindsym $mod+KP_1 workspace number 1
      bindsym $mod+2 workspace number 2
      bindsym $mod+KP_2 workspace number 2
      bindsym $mod+3 workspace number 3
      bindsym $mod+KP_3 workspace number 3
      bindsym $mod+4 workspace number 4
      bindsym $mod+KP_4 workspace number 4
      bindsym $mod+5 workspace number 5
      bindsym $mod+KP_5 workspace number 5
      bindsym $mod+6 workspace number 6
      bindsym $mod+KP_6 workspace number 6
      bindsym $mod+7 workspace number 7
      bindsym $mod+KP_7 workspace number 7
      bindsym $mod+8 workspace number 8
      bindsym $mod+KP_8 workspace number 8
      bindsym $mod+9 workspace number 9
      bindsym $mod+KP_9 workspace number 9
      bindsym $mod+0 workspace number 10
      bindsym $mod+KP_0 workspace number 10

      # Move workspaces with ctrl+mod
      bindsym $mod+Ctrl+$left workspace prev
      bindsym $mod+Ctrl+$right workspace next
      bindsym $mod+Ctrl+Left workspace prev
      bindsym $mod+Ctrl+Right workspace next

      # Move focused container to workspace
      bindsym $mod+Shift+1 move container to workspace number 1
      bindsym $mod+Shift+2 move container to workspace number 2
      bindsym $mod+Shift+3 move container to workspace number 3
      bindsym $mod+Shift+4 move container to workspace number 4
      bindsym $mod+Shift+5 move container to workspace number 5
      bindsym $mod+Shift+6 move container to workspace number 6
      bindsym $mod+Shift+7 move container to workspace number 7
      bindsym $mod+Shift+8 move container to workspace number 8
      bindsym $mod+Shift+9 move container to workspace number 9
      bindsym $mod+Shift+0 move container to workspace number 10

      bindsym $mod+Ctrl+Shift+$left move container to workspace prev
      bindsym $mod+Ctrl+Shift+$right move container to workspace next
      bindsym $mod+Ctrl+Shift+Left move container to workspace prev
      bindsym $mod+Ctrl+Shift+Right move container to workspace next

      # Note: workspaces can have any name you want, not just numbers.
      # We just use 1-10 as the default.

      #
      # Layout stuff:
      #
      # You can "split" the current object of your focus with
      # $mod+b or $mod+v, for horizontal and vertical splits
      # respectively.
      bindsym $mod+b splith
      bindsym $mod+v splitv

      # Switch the current container between different layout styles
      bindsym $mod+s layout stacking
      bindsym $mod+w layout tabbed
      bindsym $mod+e layout toggle split

      # Make the current focus fullscreen
      bindsym $mod+f fullscreen

      # Toggle the current focus between tiling and floating mode
      bindsym $mod+Shift+space floating toggle

      # Swap focus between the tiling area and the floating area
      bindsym $mod+space focus mode_toggle

      # Move focus to the parent container
      bindsym $mod+a exec $web

      # Create a lockscreen bind
      bindsym $mod+o exec $lockscreen

      default_border pixel 1
      hide_edge_borders smart

      #
      # Status Bar:
      #
      # Read `man 5 sway-bar` for more information about this section.
      bar {
        position top

        # Run waybar instead of swaybar
        swaybar_command $statusbar
      }

      #\                               /#
      # |  Resize Mode Configuration  | #
      #/                               \#

      set $mode_resize "<span foreground='$base0A'></span>  \
        <span foreground='$base05'><b>Resize</b></span> <span foreground='$base0A'>(<b>h/j/k/l</b>)</span> \
        <span foreground='$base01'>—</span> \
        <span foreground='$base05'><b>Increase Gaps</b></span> <span foreground='$base0A'>(<b>+</b>)</span> \
        <span foreground='$base01'>—</span> \
        <span foreground='$base05'><b>Decrease Gaps</b></span> <span foreground='$base0A'>(<b>-</b>)</span>"

      mode --pango_markup $mode_resize {
        # left will shrink the containers width
        # right will grow the containers width
        # up will shrink the containers height
        # down will grow the containers height
        bindsym $left resize shrink width 10px
        bindsym $down resize grow height 10px
        bindsym $up resize shrink height 10px
        bindsym $right resize grow width 10px
        bindsym Shift+$left resize shrink width 20px
        bindsym Shift+$down resize grow height 20px
        bindsym Shift+$up resize shrink height 20px
        bindsym Shift+$right resize grow width 20px

        # Ditto, with arrow keys
        bindsym Left resize shrink width 10px
        bindsym Down resize grow height 10px
        bindsym Up resize shrink height 10px
        bindsym Right resize grow width 10px
        bindsym Shift+Left resize shrink width 20px
        bindsym Shift+Down resize grow height 20px
        bindsym Shift+Up resize shrink height 20px
        bindsym Shift+Right resize grow width 20px

        ## Resize // Window Gaps // + - ##
        bindsym minus gaps inner current minus 5px
        bindsym plus gaps inner current plus 5px

        # Return to default mode
        bindsym Return mode "default"
        bindsym Escape mode "default"
      }
      bindsym $mod+r mode $mode_resize

      #\                                   /#
      # |  Screenshot Mode Configuration  | #
      #/                                   \#

      set $mode_screenshot "<span foreground='$base0A'></span>  \
        <span foreground='$base05'><b>Fullscreen</b></span> <span foreground='$base0A'>(<b>f</b>)</span> \
        <span foreground='$base01'>—</span> \
        <span foreground='$base05'><b>Window</b></span> <span foreground='$base0A'>(<b>w</b>)</span> \
        <span foreground='$base01'>—</span> \
        <span foreground='$base05'><b>Region</b></span> <span foreground='$base0A'>(<b>r</b>)</span>"

      mode --pango_markup $mode_screenshot {
        bindsym f exec --no-startup-id grimshot --notify copy screen, mode "default"
        bindsym Shift+f exec --no-startup-id grimshot --notify save screen ~/Pictures/screenshot-$(date +'%Y-%m-%d-%H%M%S').png, mode "default"
        bindsym w exec --no-startup-id grimshot --notify copy win, mode "default"
        bindsym Shift+w exec --no-startup-id grimshot --notify save win ~/Pictures/screenshot-$(date +'%Y-%m-%d-%H%M%S').png, mode "default"
        bindsym r exec --no-startup-id grimshot --notify copy area, mode "default"
        bindsym Shift+r exec --no-startup-id grimshot --notify save area ~/Pictures/screenshot-$(date +'%Y-%m-%d-%H%M%S').png, mode "default"

        # Return to default mode.
        bindsym Escape mode "default"
        bindsym Return mode "default"
      }
      bindsym $mod+Shift+s mode $mode_screenshot

      #\                                  /#
      # |  Recording Mode Configuration  | #
      #/                                  \#

      set $mode_recording "<span foreground='$base0A'>雷</span>  \
      <span foreground='$base05'><b>Screen</b></span> <span foreground='$base0A'>(<b>w</b>)</span> \
      <span foreground='$base01'>—</span> \
      <span foreground='$base05'><b>Screen (+ Mic)</b></span> <span foreground='$base0A'>(<b>Shift+w</b>)</span> \
      <span foreground='$base01'>—</span> \
      <span foreground='$base05'><b>Region</b></span> <span foreground='$base0A'>(<b>r</b>)</span> \
      <span foreground='$base01'>—</span> \
      <span foreground='$base05'><b>Region (+ Mic)</b></span> <span foreground='$base0A'>(<b>Shift+r</b>)</span>"

      set $mode_recording_on "<span foreground='$base0A'>壘</span>  \
      <span foreground='$base05'><b>Exit</b></span> <span foreground='$base0A'>(<b>ESC</b>)</span>"

      mode --pango_markup $mode_recording_on {
          bindsym Escape exec killall -s SIGINT wf-recorder, mode "default"
      }

      mode --pango_markup $mode_recording {
          bindsym w exec killall -s SIGINT wf-recorder || wf-recorder --audio=0 -o $(${user-bins.swaymsg} -t get_outputs | jq -r '.[] | select(.focused) | .name') \
                  -f ~/Videos/recording-$(date +'%Y-%m-%d-%H%M%S').mp4, mode $mode_recording_on
          bindsym Shift+w exec killall -s SIGINT wf-recorder || wf-recorder --audio -o $(${user-bins.swaymsg} -t get_outputs | jq -r '.[] | select(.focused) | .name') \
                  -f ~/Videos/recording-$(date +'%Y-%m-%d-%H%M%S').mp4, mode $mode_recording_on
          bindsym r exec killall -s SIGINT wf-recorder || wf-recorder --audio=0 -g "$(slurp -d)" \
                  -f ~/Videos/recording-$(date +'%Y-%m-%d-%H%M%S').mp4, mode $mode_recording_on
          bindsym Shift+r exec killall -s SIGINT wf-recorder || wf-recorder --audio -g "$(slurp -d)" \
                  -f ~/Videos/recording-$(date +'%Y-%m-%d-%H%M%S').mp4, mode $mode_recording_on

          # Return to default mode.
          bindsym Escape mode "default"
          bindsym Return mode "default"
      }
      bindsym $mod+Shift+r mode $mode_recording

      #
      # Scratchpad:
      #
      # Sway has a "scratchpad", which is a bag of holding for windows.
      # You can send windows there and get them back later.

      # Move the currently focused window to the scratchpad
      bindsym $mod+Shift+minus move scratchpad

      # Show the next scratchpad window or hide the focused scratchpad window.
      # If there are multiple scratchpad windows, this command cycles through them.
      bindsym $mod+minus scratchpad show

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
        "on-click": "wlogout"
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
        "on-click": "nm-connection-editor"
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
        "format-icons": ["", ""],
        "on-scroll-down": "light -A 1",
        "on-scroll-up": "light -U 1"
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
      font-family: "FontAwesome 5 Free Solid", "Noto Sans", Roboto, sans-serif;
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
      "action": "systemctl hibernate",
      "text": "Hibernate",
      "keybind": "h"
    }
    {
      "label": "logout",
      "action": "loginctl terminate-user $USER",
      "text": "Logout",
      "keybind": "e"
    }
    {
      "label" : "shutdown",
      "action" : "systemctl poweroff",
      "text" : "Shutdown",
      "keybind" : "s"
    }
    {
      "label" : "suspend",
      "action" : "systemctl suspend",
      "text" : "Suspend",
      "keybind" : "u"
    }
    {
      "label" : "reboot",
      "action" : "systemctl reboot",
      "text" : "Reboot",
      "keybind" : "r"
    }
  '';

  services.kanshi = {
    enable = true;

    profiles = {
      undocked.outputs = [{
        criteria = "eDP-1";
        status = "enable";
      }];
      docked.outputs = [
        {
          criteria = "eDP-1";
          status = "disable";
        }
        {
          criteria = "ViewSonic Corporation VP211b A22050300003";
          status = "enable";
        }
        {
          criteria = "Samsung Electric Company SMS27A350H 0x00007F36";
          status = "enable";
        }
      ];
    };
  };

  # Config for workstyle
  #
  # Format:
  # "pattern" = "icon"
  #
  # The pattern will be used to match against the application name.
  # The icon will be used to represent that application.
  #
  # Note if multiple patterns are present in the same application name,
  # precedence is given in order of apparition in this file.
  xdg.configFile."workstyle/config.toml".text = ''
    "alacritty" = ""
    "kitty" = ""
    "github" = ""
    "rust" = ""
    "google" = ""
    "private browsing" = ""
    "firefox" = ""
    "thunderbird" = ""
    "chrome" = ""
    "file manager" = ""
    "libreoffice calc" = ""
    "libreoffice writer" = ""
    "libreoffice" = ""
    "bash" = ""
    "nvim" = ""
    "gthumb" = ""
    "menu" = ""
    "calculator" = ""
    "transmission" = ""
    "videostream" = ""
    "mpv" = ""
    "music" = ""
    "disk usage" = ""
    ".pdf" = ""
    "remmina" = ""
    "microsoft teams" = ""
    "element" = ""
    "discord" = ""
    "obsidian" = ""
    "qutebrowser" = ""

    [other]
    "fallback_icon" = "🤨"
  '';
}
