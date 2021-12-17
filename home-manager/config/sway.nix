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
}
