{ config, pkgs, ... }: {
  imports = [ ./base-desktop.nix ];

  xdg.configFile."waybar/config".text = ''
    // =============================================================================
    //
    // Waybar configuration
    //
    // Configuration reference: https://github.com/Alexays/Waybar/wiki/Configuration
    //
    // =============================================================================

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

  xdg.configFile."waybar/style.css".text = ''
    /* =============================================================================
     *
     * Waybar configuration
     *
     * Configuration reference: https://github.com/Alexays/Waybar/wiki/Configuration
     *
     * =============================================================================
     */

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

  xdg.configFile."kanshi/config".text = ''
    profile {
        output eDP-1 enable
    }

    profile docked {
        output eDP-1 disable
        output "ViewSonic Corporation VP211b A22050300003" enable
        output "Samsung Electric Company SMS27A350H 0x00007F36" enable
    }
  '';
}
