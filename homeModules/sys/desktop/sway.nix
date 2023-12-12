{ config, lib, pkgs, ... }:

let
  cfg = config.sys.desktop.sway;

  maxWorkspaces = 9; # Only 9 number keys, with 0 used for "last workspace"

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

  mapListToAttrs' = f: list: builtins.listToAttrs (builtins.map f list);
  pipeShellCmds = builtins.concatStringsSep " | ";
  xor = a: b: (!a && b) || (a && !b);
  # xnor = a: b: (a && b) || (!a && !b);
  nz = x: y: if x == null then y else x;

  # TODO: Refactor?
  mkScreenConfig =
    { name
    , id ? null
    , outputString ? null
    , xPixels
    , yPixels
    , refreshRate
    , scale ? 1.0
    }:
      assert builtins.isString name;
      assert id == null || builtins.isString id;
      assert outputString == null || builtins.isString outputString;
      assert builtins.isInt xPixels;
      assert builtins.isInt yPixels;
      assert builtins.isFloat refreshRate || builtins.isInt refreshRate;
      assert builtins.isFloat scale;
      assert xor (id != null) (outputString != null);
      {
        inherit name refreshRate scale xPixels yPixels;

        mode = "${builtins.toString xPixels}x${builtins.toString yPixels}@${builtins.toString refreshRate}Hz";

        # criteria = if id != null then id else outputString;
        criteria = nz id outputString;

        xPixelsOut = builtins.ceil (xPixels * (1 / scale));
        yPixelsOut = builtins.ceil (yPixels * (1 / scale));
      };

  screens = {
    builtin = mkScreenConfig {
      name = "Built-in display";
      id = "eDP-1";
      scale = 1.5;
      xPixels = 2256;
      yPixels = 1504;
      refreshRate = 59.999;
    };

    homeDockCenter = mkScreenConfig {
      name = "ASUS High Refresh-Rate Monitor";
      outputString = "ASUSTek COMPUTER INC VG28UQL1A 0x0000135C";
      # scale = 1.75;
      xPixels = 1920; # 3840; # NOTE: Wish I could afford better.
      yPixels = 1080; # 2160;
      refreshRate = 50; # 30; # High refresh rate, but can't run it at such
    };

    homeDockLeft = mkScreenConfig {
      name = "ASUS Low Refresh-Rate Monitor";
      outputString = "ASUSTek COMPUTER INC VA279 N2LMQS025509";
      xPixels = 1920;
      yPixels = 1080;
      refreshRate = 50;
    };

    homeDockRight = mkScreenConfig {
      name = "ViewSonic 4:3 Monitor";
      outputString = "ViewSonic Corporation VP211b A22050300003";
      xPixels = 1600;
      yPixels = 1200;
      refreshRate = 60;
    };

    homeDockRightFallback = mkScreenConfig {
      name = "ViewSonic 4:3 Monitor Fallback";
      outputString = "<Unknown> <Unknown> "; # The displayport to DVI adapter likes to act up
      xPixels = 1024;
      yPixels = 768;
      refreshRate = 60.004;
    };

    # Functions
    screenOrder = builtins.map (builtins.getAttr "criteria");
  };

  defaultScreenCenter = with screens; screenOrder [
    homeDockCenter
    homeDockLeft
    homeDockRight
    homeDockRightFallback
    builtin
  ];

  defaultScreenLeft = with screens; screenOrder [
    homeDockLeft
    homeDockCenter
    homeDockRight
    homeDockRightFallback
    builtin
  ];

  defaultScreenRight = with screens; screenOrder [
    homeDockRight
    homeDockRightFallback
    homeDockCenter
    homeDockLeft
    builtin
  ];

  defaultScreenLaptop = with screens; screenOrder [
    builtin
    homeDockLeft
    homeDockRight
    homeDockRightFallback
    homeDockCenter
  ];
in
{
  options.sys.desktop.sway = {
    enable = lib.mkEnableOption "Enable personal SwayWM config";

    package = lib.mkPackageOption pkgs "sway" { };
    mixerPackage = lib.mkPackageOption pkgs "pamixer" { };
    lockscreenPackage = lib.mkPackageOption pkgs "swaylock-effects" { };
    logoutPackage = lib.mkPackageOption pkgs "wlogout" { };

    workspaces = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule (_: {
        options = {
          index = lib.mkOption {
            type = lib.types.ints.between 1 9;

            description = ''
              Index and number key assigned to workspace (1-9)
            '';
          };

          isDefault = lib.mkOption {
            type = lib.types.bool;
            default = false;
            internal = true;
          };

          title = lib.mkOption {
            type = with lib.types; nullOr str;
            default = null;
            description = "Text to display for the workspace";
          };

          icon = lib.mkOption {
            type = with lib.types; nullOr str;
            default = null;
            description = "Unicode icon to display for the workspace";
          };

          mappedKeys = lib.mkOption {
            type = with lib.types; listOf str;
            default = [ ];
            description = ''
              Keys to use for both selection and window moving. Always includes
              the index by default.
            '';
          };

          assigns = lib.mkOption {
            type = with lib.types; listOf (attrsOf str);
            default = [ ];
            description = "pattern matches to use to assign windows";
          };

          outputs = lib.mkOption {
            type = with lib.types; listOf str;
            default = defaultScreenLaptop;
            description = "Where to put the workspace by default";
          };
        };
      }));

      default = [
        {
          index = 1;
          icon = "󰖟 ";
          title = "Web";
          outputs = defaultScreenLeft;
          assigns = [{ app_id = "^firefox$"; }];
        }
        {
          index = 2;
          icon = "󰍲 ";
          title = "Microsoft Teams";
          outputs = defaultScreenRight;

          assigns = [
            # Microsoft Edge X11
            { class = "^Microsoft-edge$"; }
            { instance = "^microsoft-edge$"; }

            # Teams-For-Linux Wayland
            { app_id = "^teams-for-linux$"; }

            # Teams-For-Linux X11
            { class = "^teams-for-linux$"; }
            { instance = "^teams-for-linux$"; }
          ];
        }
        {
          index = 3;
          icon = "󰭹 ";
          title = "Matrix";
          outputs = defaultScreenRight;

          # Element is a little finicky
          assigns = [
            { class = "^Element$"; }
            { instance = "^element$"; }
            { title = "^Element"; }
            { app_id = "^nehko$"; }
            { title = "^nheko"; }
          ];
        }
        {
          index = 4;
          icon = "󰙯 ";
          title = "Discord";
          outputs = defaultScreenRight;

          assigns = [
            { instance = "^discord$"; }
            { title = "^Discord$"; }
            { title = "^Discord Updater$"; }
            { app_id = "WebCord"; }
          ];
        }
        {
          index = 5;
          icon = "󰇮 ";
          title = "Email";
          outputs = defaultScreenLeft;
        }
        {
          index = 6;
          isDefault = true;
          icon = "";
          title = "Etc 1";
          outputs = defaultScreenCenter;
        }
        {
          index = 7;
          isDefault = true;
          icon = "";
          title = "Etc 2";
          outputs = defaultScreenCenter;
        }
        {
          index = 8;
          isDefault = true;
          icon = "";
          title = "Etc 3";
          outputs = defaultScreenCenter;
        }
        {
          index = 9;
          isDefault = true;
          icon = "";
          title = "Etc 4";
          outputs = defaultScreenCenter;
        }
      ];

      description = ''
        Workspace configurations
      '';
    };

    dmenu = lib.mkOption {
      type = lib.types.submodule (_: {
        options = {
          enable = lib.mkEnableOption "dmenu system" // { default = true; };

          package = lib.mkPackageOption pkgs "rofi-wayland" { };
        };
      });

      default = { };
    };

    kanshi = lib.mkOption {
      type = lib.types.submodule (_: {
        options = {
          enable = lib.mkEnableOption "dynamic display config" // { default = true; };

          package = lib.mkPackageOption pkgs "kanshi" { };
        };
      });

      default = { };
    };

    backlight = lib.mkOption {
      type = lib.types.submodule (_: {
        options = {
          package = lib.mkPackageOption pkgs "light" { };

          increaseCmd = lib.mkOption {
            type = lib.types.str;
            default = "-A 5";
          };

          decreaseCmd = lib.mkOption {
            type = lib.types.str;
            default = "-U 5";
          };
        };
      });

      default = { };
    };

    mako = {
      enable = lib.mkEnableOption "notifications system" // { default = true; };

      package = lib.mkPackageOption pkgs "mako" { };
      notifysendPackage = lib.mkPackageOption pkgs "libnotify" { };
    };

    playerctl = lib.mkOption {
      type = lib.types.submodule (_: {
        options = {
          enable = lib.mkEnableOption "music control" // { default = true; };

          package = lib.mkPackageOption pkgs "playerctl" { };
        };
      });

      default = { };
    };

    screenRecording = lib.mkOption {
      type = lib.types.submodule (_: {
        options = {
          enable = lib.mkEnableOption "screen recording software" // { default = true; };

          slurpPackage = lib.mkPackageOption pkgs "slurp" { };
          wf-recorderPackage = lib.mkPackageOption pkgs "wf-recorder" { };
        };
      });

      default = { };
    };

    screenshots = lib.mkOption {
      type = lib.types.submodule (_: {
        options = {
          enable = lib.mkEnableOption "screenshot software" // { default = true; };

          grimshotPackage = lib.mkPackageOption pkgs.sway-contrib "grimshot" { };
        };
      });

      default = { };
    };

    swayidle = lib.mkOption {
      type = lib.types.submodule (_: {
        options = {
          enable = lib.mkEnableOption "idle daemon" // { default = true; };

          package = lib.mkPackageOption pkgs "swayidle" { };
        };
      });

      default = { };
    };

    waybar = lib.mkOption {
      type = lib.types.submodule (_: {
        options = {
          enable = lib.mkEnableOption "waybar system" // { default = true; };

          package = lib.mkPackageOption pkgs "waybar" { };

          desktopMixerPackage = lib.mkPackageOption pkgs "pavucontrol" { };
        };
      });

      default = { };
    };
  };

  config = lib.mkIf cfg.enable (
    let
      # Use start/logo key for modifiers
      modifier = "Mod4";

      # lockscreen :: String
      swaylock = [
        (lib.getExe cfg.lockscreenPackage)
        "--daemonize"
        "--show-failed-attempts"
        "--image"
        "${config.home.homeDirectory or "$HOME"}/lockscreen.jpg"
        "--clock"
        "--indicator"
        #"--effect-blur" "7x5"
        "--effect-vignette"
        "0.5:0.5"
        "--fade-in"
        "0.2"
      ];

      lockscreen = lib.escapeShellArgs swaylock;
      idlelock = builtins.concatStringsSep " " swaylock;

      # mkDefaultWorkspace :: Int -> Int -> Workspace
      mkDefaultWorkspace = offset: index:
        assert builtins.isInt index;
        assert builtins.isInt offset;

        {
          index = index + offset;
          isDefault = true;
          icon = "";
          title = "Etc ${builtins.toString index}";
          outputs = defaultScreenCenter;
        };

      # mkExpandedWorkspaces :: [Workspace] -> [Workspace]
      mkExpandedWorkspaces = workspaces:
        let
          # mkDefaultSpaces :: Int -> Int -> [Workspace]
          mkDefaultSpaces = len:
            builtins.genList (mkDefaultWorkspace len);
          # len :: Int
          len = builtins.length workspaces;
        in
        workspaces ++ lib.optionals (len < maxWorkspaces) (mkDefaultSpaces (maxWorkspaces - len));

      # mkIndexList :: Int -> [Int]
      # mkIndexList = builtins.genList (builtins.add 1);

      # mkIndexListOfAttrs :: Int -> [{ index :: Int }]
      # mkIndexListOfAttrs = len:
      #   builtins.map (i: { index = i + 1; }) (mkIndexList len);

      # addIndexToListOfAttrs :: [AttrSet] -> [AttrSet]
      # addIndexToListOfAttrs = attrlist:
      #   let
      #     equalSizedIndexList = mkIndexListOfAttrs (builtins.length attrlist);
      #   in
      #   lib.zipListsWith lib.mergeAttrs attrlist equalSizedIndexList;

      /* Perform final attribute cleanup to produce a final workspace for addition.

        Type:
        mkFinalWorkspace :: { index :: Int, icon :: String, title :: String, mappedKeys :: [AttrSet]} -> FinalWorkspace
      */
      mkFinalWorkspace = { index, icon, title, mappedKeys ? [ ], ... }@args: args // {
        keys = lib.unique (mappedKeys ++ [ "${builtins.toString index}" ]);
        name = "${builtins.toString index}: ${icon} ${title}";
      };

      /* Create workspace switch key assignment

        Type:
        mkSwitchKeyAssign :: String -> String -> String -> NameValuePair
      */
      mkSwitchKeyAssign = modKey: name: key:
        { name = "${modKey}+${key}"; value = "workspace \"${name}\""; };

      /* Create workspace move key assignment

        Type:
        mkMoveKeyAssign :: String -> String -> String -> NameValuePair
      */
      mkMoveKeyAssign = modKey: name: key:
        { name = "${modKey}+Shift+${key}"; value = "move container to workspace \"${name}\""; };

      /* Create assignments for each workspace:

        Type:
        mkKeyAssigns :: String -> ({ keys :: [String], name :: String } -> AttrSet) -> [FinalWorkspace] -> AttrSet
      */
      mkKeyAssigns = modKey: mkFunc: list:
        builtins.foldl' lib.mergeAttrs { } (lib.flatten (builtins.map ({ keys, name, ... }: mapListToAttrs' (mkFunc modKey name) keys) list));

      # mkIndexedWorkspaces :: [Workspace] -> [IndexedWorkspace]
      # mkIndexedWorkspaces = w: addIndexToListOfAttrs (mkExpandedWorkspaces w);

      # mkFinalWorkspaces :: [Workspace] -> [FinalWorkspace]
      mkFinalWorkspaces = w: builtins.map mkFinalWorkspace (mkExpandedWorkspaces w);

      finalWorkspaces = mkFinalWorkspaces cfg.workspaces;
    in
    lib.mkMerge [
      {
        # TODO: Make conditional on enabling an electron App
        home.sessionVariables."NIXOS_OZONE_WL" = 1;

        wayland.windowManager.sway = {
          inherit (cfg) package enable;

          wrapperFeatures.gtk = true;
          systemd.enable = true;

          config =
            let
              # Use (n)vim-like keybindings
              left = "h";
              right = "l";
              up = "k";
              down = "j";

              # Shutdown command
              shutdown = "${lib.getExe cfg.logoutPackage} --buttons-per-row 3";
            in
            {
              inherit modifier left right up down;

              # Set the terminal
              terminal = config.home.sessionVariables.TERMINAL or (lib.getExe pkgs.xterm);

              # Configure XWayland seat
              seat.seat0.hide_cursor = "when-typing enable";

              # Use some of the default keybindings w/ `lib.mkOptionDefault`
              keybindings = lib.mkOptionDefault ({
                # Media key bindings
                "XF86AudioMute" = "exec ${lib.getExe cfg.mixerPackage} -t";
                "XF86AudioLowerVolume" = "exec ${lib.getExe cfg.mixerPackage} -d 2";
                "XF86AudioRaiseVolume" = "exec ${lib.getExe cfg.mixerPackage} -i 2";

                # Screen brightness bindings
                "XF86MonBrightnessDown" = "exec '${lib.escapeShellArgs [ (lib.getExe cfg.backlight.package) cfg.backlight.decreaseCmd ]}'";
                "XF86MonBrightnessUp" = "exec '${lib.escapeShellArgs [ (lib.getExe cfg.backlight.package) cfg.backlight.increaseCmd ]}'";

                # Capture PowerOff key
                "XF86PowerOff" = "exec ${shutdown}";

                # Define our own shutdown command
                "${modifier}+Shift+e" = "exec ${shutdown}";

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
                "${modifier}+a" = "exec ${config.home.sessionVariables.BROWSER or (lib.getExe pkgs.chromium)}";

                # Create a binding for the lock screen. Something close to $modifier+l
                "${modifier}+o" = "exec ${lockscreen}";

                # Create bindings for modes
                "${modifier}+r" = "mode \"resize\"";
                "${modifier}+Shift+s" = "mode \"screenshot\"";
                "${modifier}+Shift+r" = "mode \"recording\"";
              }
              // mkKeyAssigns modifier mkSwitchKeyAssign finalWorkspaces
              // mkKeyAssigns modifier mkMoveKeyAssign finalWorkspaces
              );

              input = {
                "type:keyboard".xkb_options = "caps:escape";

                "1:1:AT_Translated_Set_2_keyboard" = {
                  xkb_layout = "us";
                  xkb_numlock = "enabled";
                };

                "type:touchpad" = {
                  dwt = "enabled";
                  tap = "enabled";
                };

                "2362:628:PIXA3854:00_093A:0274_Touchpad" = {
                  accel_profile = "flat";
                  pointer_accel = "1";
                  natural_scroll = "disabled";
                };
              };

              ### Organize startup programs
              # For how the home-manager module is written as of 2022-01-05, the
              #   workspace argument isn't quoted, technically allowing for using
              #   number name syntax, but unfortunately causing workspaces with
              #   spaces in their name to not load correctly. Workaround is quoting
              #   the workspace name.
              #
              # NOTE: See https://github.com/nix-community/home-manager/blob/master/modules/services/window-managers/i3-sway/lib/functions.nix#L55
              #
              # TODO: Replace DiscordCanary with a wayland-compatible electron app
              #
              assigns =
                mapListToAttrs' ({ name, assigns, ... }: { name = "\"${name}\""; value = assigns; }) (builtins.filter ({ assigns, ... }: (builtins.length assigns) > 0) finalWorkspaces);

              bars = lib.optionals cfg.waybar.enable [{
                fonts = {
                  names = [ "Fira Sans" "sans-serif" ];
                  style = "Bold Semi-Condensed";
                  size = 14.0;
                };

                position = "top";
                command = lib.getExe cfg.waybar.package;
              }];

              floating = {
                border = 1;

                criteria = [
                  { title = "^Steam - News$"; }
                  { title = "^Friends List$"; }
                  { app_id = "^pavucontrol$"; }
                  { app_id = "^firefox$"; title = "^About Mozilla Firefox$"; }
                  { app_id = "^firefox$"; title = "^Firefox — Sharing Indicator$"; }
                  { app_id = "^firefox$"; title = "^Extension: (NoScript) - NoScript Settings — Mozilla Firefox$"; }
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
                      timestampBash = "$(${pkgs.coreutils}/bin/date +${timestampFormat})";
                    in
                    dir: prefix: type:
                      "${dir}/${prefix}-${timestampBash}.${type}";

                  killRecorder = "exec ${pkgs.procps}/bin/pkill wf-recorder";
                in
                {
                  resize =
                    let
                      sizes = with sizes; {
                        tiny = 5;
                        small = tiny * 2;
                        large = small * 2;
                      };

                      sizeMap = builtins.mapAttrs (_: v: "${builtins.toString v}px") sizes;
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
                      screenshot-file = outFile (config.xdg.userDirs.pictures or "$HOME/Pictures") "screenshot" "png";
                      capture = action: area:
                        "exec --no-startup-id ${lib.getExe cfg.screenshots.grimshotPackage} --notify ${action} ${area} ${lib.optionalString (action == "save") screenshot-file}, ${exit-mode}";

                      keyMap = {
                        "f" = "screen";
                        "w" = "win";
                        "r" = "area";
                      };
                    in
                    builtins.mapAttrs (_: capture "copy") keyMap
                    // lib.mapAttrs' (n: v: lib.nameValuePair "Shift+${n}" (capture "save" v)) keyMap
                    // exitModeKeys;

                  recording_on."Escape" = "${killRecorder}, ${exit-mode}";

                  recording =
                    let
                      recording-mode = "mode \"recording_on\"";
                      recording-file = outFile (config.xdg.userDirs.videos or "$HOME/Videos") "recording" "mp4";

                      areas = {
                        win = {
                          command = "$(${cfg.package}/bin/swaymsg -t get_outputs | ${lib.getExe pkgs.jq} -r '.[] | select(.focused) | .name')";
                          arg = "-o";
                        };

                        area = {
                          command = "\"$(${lib.getExe cfg.screenRecording.slurpPackage} -d)\"";
                          arg = "-g";
                        };
                      };

                      audioBln = a: "--audio${if a then "" else "=0"}";

                      keyMap = {
                        "w" = "win";
                        "r" = "area";
                      };

                      mkCapture = audio: area:
                        "${killRecorder} || ${lib.getExe cfg.screenRecording.wf-recorderPackage} ${audioBln audio} ${areas.${area}.arg} ${areas.${area}.command} -f ${recording-file}, ${recording-mode}";
                    in
                    builtins.mapAttrs (_: mkCapture true) keyMap
                    // lib.mapAttrs' (n: v: lib.nameValuePair "Shift+${n}" (mkCapture false v)) keyMap
                    // exitModeKeys;
                };

              # Default to outputting some workspaces on other monitors if available
              workspaceOutputAssign =
                builtins.map ({ name, outputs, ... }: { output = outputs; workspace = name; }) finalWorkspaces;

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

          extraConfig = builtins.concatStringsSep "\n" (builtins.map ({ name, ... }: "workspace \"${name}\"") (lib.reverseList finalWorkspaces));
        };

        ### Power Menu
        # Provide a power/logout menu.
        #
        # TODO: Make into a home-manager module?
        #
        xdg.configFile."wlogout/layout".text =
          let
            systemctl = "${pkgs.systemd}/bin/systemctl";
            loginctl = "${pkgs.systemd}/bin/loginctl";
          in
          ''
            {
              "label": "lock",
              "action": "${lockscreen}",
              "text" : "Lock",
              "keybind": "1"
            }
            {
              "label": "hibernate",
              "action": "${systemctl} hibernate",
              "text": "Hibernate",
              "keybind": "h"
            }
            {
              "label": "logout",
              "action": "${loginctl} terminate-user $USER",
              "text": "Logout",
              "keybind": "i"
            }
            {
              "label" : "shutdown",
              "action" : "${systemctl} poweroff",
              "text" : "Shutdown",
              "keybind" : "u"
            }
            {
              "label" : "suspend",
              "action" : "${systemctl} suspend",
              "text" : "Suspend",
              "keybind" : "s"
            }
            {
              "label" : "reboot",
              "action" : "${systemctl} reboot",
              "text" : "Reboot",
              "keybind" : "r"
            }
          '';

        systemd.user.services.sway-polkit-authentication-agent = {
          Unit = {
            Description = "Sway Polkit authentication agent";
            Documentation = "https://gitlab.freedesktop.org/polkit/polkit";
            After = [ "graphical-session-pre.target" ];
            # PartOf = [ "graphical-session.target" ];
          };

          Service = {
            Type = "exec";
            ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
            BusName = "org.freedesktop.PolicyKit1.Authority";
          };

          Install.WantedBy = [ "graphical-session.target" ];
        };
      }

      (lib.mkIf cfg.waybar.enable {
        ### Waybar configuration
        # Configuration for a status bar provided by waybar.
        #
        # NOTE: See https://github.com/Alexays/Waybar/wiki/Configuration
        #
        xdg.configFile."waybar/config".source = (pkgs.formats.json { }).generate "waybar-config.json" {
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

            format-charging = " {icon}  {capacity}%"; # Icon: bolt
            format = "{icon}  {capacity}%";

            format-icons = [
              " " # Icon: battery-empty
              " " # Icon: battery-quarter
              " " # Icon: battery-half
              " " # Icon: battery-three-quarters
              " " # Icon: battery-full
            ];

            tooltip = false;
          };

          clock = {
            interval = 60;
            format = "  {:%e %b %Y %H:%M}"; # Icon: calendar-alt
            tooltip = false;
            on-click = lib.escapeShellArgs [ (lib.getExe cfg.logoutPackage) "--buttons-per-row" "3" ];
          };

          cpu = {
            interval = 5;
            format = "   {usage}%"; # Icon: microchip

            states = {
              warning = 70;
              critical = 90;
            };
          };

          memory = {
            interval = 5;
            format = "   {}%"; # Icon: memory

            states = {
              warning = 70;
              critical = 90;
            };
          };

          network = {
            interval = 5;
            format-wifi = "󰖩   {essid} ({signalStrength}%)"; # Icon: wifi
            format-ethernet = "󰈀   {ifname}: {ipaddr}/{cidr}"; # Icon: ethernet
            format-disconnected = "󰌙   Disconnected";
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
            format-icons = [ "󱃓 " "󰪞 " "󰪟 " "󰪠 " "󰪡 " "󰪢 " "󰪣 " "󰪤 " "󰪥 " ];
            on-scroll-down = lib.escapeShellArgs [ (lib.getExe cfg.backlight.package) cfg.backlight.decreaseCmd ];
            on-scroll-up = lib.escapeShellArgs [ (lib.getExe cfg.backlight.package) cfg.backlight.increaseCmd ];
          };

          pulseaudio = {
            format = "{icon}  {volume}%";
            format-bluetooth = "{icon}  {volume}%";
            format-muted = "󰝟 ";

            format-icons = {
              headphones = " ";
              handsfree = " ";
              headset = " ";
              phone = " ";
              portable = " ";
              car = " ";
              default = [ "󰕿 " "󰖀 " "󰕾 " ];
            };

            on-scroll-down = "${lib.getExe cfg.mixerPackage} -d 2";
            on-scroll-up = "${lib.getExe cfg.mixerPackage} -i 2";
            on-click = lib.getExe cfg.waybar.desktopMixerPackage;
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
            background: @warning_color;
          }

          #battery.critical {
            background: @error_color;
          }

          #clock {
            font-weight: bold;
          }

          #cpu {
            /* No styles */
          }

          #cpu.warning {
            background: @warning_color;
          }

          #cpu.critical {
            background: @error_color;
          }

          #memory.warning {
            background: @warning_color;
          }

          #memory.critical {
            background: @error_color;
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
      })

      (lib.mkIf cfg.dmenu.enable (
        let
          # Your preferred application launcher
          # NOTE: pass the final command to swaymsg so that the resulting window
          #   can be opened on the original workspace that the command was run on.
          rofiDesktopMenu = lib.escapeShellArgs [ (lib.getExe cfg.dmenu.package) "-show" "drun" ];
          rofiMenu = lib.escapeShellArgs [ (lib.getExe cfg.dmenu.package) "-show" "run" ];
          xargsToSway = lib.escapeShellArgs [ "${pkgs.findutils}/bin/xargs" "${cfg.package}/bin/swaymsg" "exec" "--" ];
        in
        {
          wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {
            # Redefine menu bindings
            "${modifier}+d" = "exec '${pipeShellCmds [ rofiDesktopMenu xargsToSway ]}'";
            "${modifier}+Shift+d" = "exec '${pipeShellCmds [ rofiMenu xargsToSway ]}'";
          };

          programs.rofi = {
            inherit (cfg.dmenu) enable package;

            terminal = config.home.sessionVariables.TERMINAL or (lib.getExe pkgs.xterm);
            font = "Fira Sans 14";
            theme = "android_notification";
            extraConfig.modi = "drun,run";
          };
        }
      ))

      (lib.mkIf cfg.kanshi.enable {
        ### Kanshi Dynamic Output Daemon
        # Configure screens dynamically, since my current workstation is a laptop I
        #   may or may not have docked at the time.
        #
        services.kanshi = {
          enable = true;

          profiles = {
            undocked.outputs = [{
              inherit (screens.builtin) criteria mode scale;

              status = "enable";
            }];

            singleMonitor.outputs = [
              {
                inherit (screens.builtin) criteria mode scale;

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
                inherit (screens.builtin) criteria mode scale;
                status = "disable";
              }
              {
                inherit (screens.homeDockLeft) criteria mode scale;
                status = "enable";
                position = "0,0";
              }
              {
                inherit (screens.homeDockCenter) criteria mode scale;
                status = "enable";
                position = "${builtins.toString screens.homeDockLeft.xPixelsOut},0";
              }
              {
                inherit (screens.homeDockRight) criteria mode scale;
                status = "enable";
                position = "${builtins.toString (screens.homeDockLeft.xPixelsOut + screens.homeDockCenter.xPixelsOut)},0";
              }
            ];

            homeDockedFullFallback.outputs = [
              {
                inherit (screens.builtin) criteria mode scale;
                status = "disable";
              }
              {
                inherit (screens.homeDockLeft) criteria mode scale;
                status = "enable";
                position = "0,0";
              }
              {
                inherit (screens.homeDockCenter) criteria mode scale;
                status = "enable";
                position = "${builtins.toString screens.homeDockLeft.xPixelsOut},0";
              }
              {
                inherit (screens.homeDockRightFallback) criteria mode scale;
                status = "enable";
                position = "${builtins.toString (screens.homeDockLeft.xPixelsOut + screens.homeDockCenter.xPixelsOut)},0";
              }
            ];

            homeDockedPartialNoLeft.outputs = [
              {
                inherit (screens.builtin) criteria mode scale;
                status = "disable";
              }
              {
                inherit (screens.homeDockCenter) criteria mode scale;
                status = "enable";
                position = "0,0";
              }
              {
                inherit (screens.homeDockRight) criteria mode scale;
                status = "enable";
                position = "${builtins.toString screens.homeDockCenter.xPixelsOut},0";
              }
            ];

            homeDockedPartialNoCenter.outputs = [
              {
                inherit (screens.builtin) criteria mode scale;
                status = "disable";
              }
              {
                inherit (screens.homeDockLeft) criteria mode scale;
                status = "enable";
                position = "0,0";
              }
              {
                inherit (screens.homeDockRight) criteria mode scale;
                status = "enable";
                position = "${builtins.toString screens.homeDockLeft.xPixelsOut},0";
              }
            ];

            homeDockedPartialNoRight.outputs = [
              {
                inherit (screens.builtin) criteria mode scale;
                status = "disable";
              }
              {
                inherit (screens.homeDockLeft) criteria mode scale;
                status = "enable";
                position = "0,0";
              }
              {
                inherit (screens.homeDockCenter) criteria mode scale;
                status = "enable";
                position = "${builtins.toString screens.homeDockLeft.xPixelsOut},0";
              }
            ];
          };

          systemdTarget = "graphical-session-pre.target";
        };

        # Have kanshi restart to ensure
        home.activation.restart-kanshi =
          lib.hm.dag.entryAfter [ "reloadSystemd" ] "$DRY_RUN_CMD ${pkgs.systemd}/bin/systemctl restart $VERBOSE_ARG --user kanshi.service";
      })

      (lib.mkIf cfg.playerctl.enable {
        # Enable controlling players with media keys with playerctld
        services.playerctld.enable = true;

        # TODO: Simplify?
        wayland.windowManager.sway.config.keybindings =
          let
            playerctl = lib.getExe cfg.playerctl.package;
          in
          lib.mkOptionDefault {
            "XF86AudioNext" = lib.escapeShellArgs [ "exec" (lib.escapeShellArgs [ playerctl "next" ]) ];
            "XF86AudioPlay" = lib.escapeShellArgs [ "exec" (lib.escapeShellArgs [ playerctl "play-pause" ]) ];
            "XF86AudioPrev" = lib.escapeShellArgs [ "exec" (lib.escapeShellArgs [ playerctl "previous" ]) ];
            "XF86AudioStop" = lib.escapeShellArgs [ "exec" (lib.escapeShellArgs [ playerctl "stop" ]) ];
          };
      })

      (lib.mkIf cfg.mako.enable {
        home.packages = [ cfg.mako.notifysendPackage ];

        ### Mako Notification Daemon
        # Configure a notification daemon for Sway, providing
        #   `org.freedesktop.Notifications`.
        #
        # TODO: Add systemd service to home-manager module?
        #
        services.mako = {
          inherit (cfg.mako) enable;

          defaultTimeout = 15 * 1000;

          iconPath = lib.concatStringsSep ":" [
            "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark"
            "${pkgs.papirus-icon-theme}/share/icons/Papirus"
            "${pkgs.hicolor-icon-theme}/share/icons/hicolor"
          ];
        };

        systemd.user.services.mako = lib.mkIf cfg.mako.enable (
          let
            configFile = "${config.xdg.configHome or "$XDG_CONFIG_HOME"}/mako/config";
          in
          {
            Unit = {
              Description = "mako notification daemon for Sway";
              Documentation = "man:mako(1)";
              PartOf = [ "graphical-session-pre.target" ];
              ConditionPathExists = configFile;
            };

            Service = {
              Type = "dbus";
              ExecStart = lib.escapeShellArgs [ (lib.getExe cfg.mako.package) "--config" configFile ];
              # ExecStartPost =
              #   lib.optionalString (config.services.mpdris2.enable or false)
              #     (lib.escapeShellArgs [ "${pkgs.systemd}/bin/systemctl" "--user" "--" "restart" "mpdris2.service" ]);
              BusName = "org.freedesktop.Notifications";
            };

            Install.WantedBy = [ "graphical-session-pre.target" ];
          }
        );

        # services.poweralertd.enable = true;
      })

      (lib.mkIf cfg.swayidle.enable {

        ### Idle Daemon
        # Need an idle daemon to lock the system and turn off the screen if I step
        #   away.
        #
        # services.swayidle = {
        #   enable = true;

        #   timeouts = [
        #     {
        #       timeout = 900;
        #       command = "exec ${idlelock}";
        #     }
        #     {
        #       timeout = 960;
        #       command = "${cfg.package}/bin/swaymsg \"output * dpms off\"";
        #       resumeCommand = "${cfg.package}/bin/swaymsg \"output * dpms on\"";
        #     }
        #   ];
        #   events = [
        #     {
        #       event = "before-sleep";
        #       command = "${cfg.playerctl.package}/bin/playerctl pause";
        #     }
        #     {
        #       event = "before-sleep";
        #       command = "exec ${idlelock}";
        #     }
        #   ];
        # };
        xdg.configFile."swayidle/config".text =
          let
            lockTimer = 16 * 60; # in Seconds
            screenTimer = lockTimer + 60;
            screensOn = on: "${cfg.package}/bin/swaymsg output '*' dpms ${if on then "on" else "off"}";
          in
          # ''
            #   idlehint ${builtins.toString lockTimer}
            #   lock "${idlelock}"
            #   before-sleep "${idlelock}"
            #   timeout ${builtins.toString screenTimer} "${screensOn false}" resume "${screensOn true}"
            # '';
          ''
            timeout ${builtins.toString lockTimer} "${idlelock}"
            timeout ${builtins.toString screenTimer} "${screensOn false}" resume "${screensOn true}"
          '';

        systemd.user.services.swayidle = {
          Unit = {
            Description = "Idle manager for Wayland";
            Documentation = "man:swayidle(1)";
            PartOf = [ "graphical-session.target" ];
          };

          Service = {
            Type = "simple";
            ExecStart = "${lib.getExe cfg.swayidle.package} -w";
          };

          Install.WantedBy = [ "graphical-session.target" ];
        };

        systemd.user.targets.sway-session.Unit.Wants = [
          "graphical-session-pre.target"
        ];
      })
    ]
  );
}
