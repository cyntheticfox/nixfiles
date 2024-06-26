{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.sys.desktop.sway;
in
{
  options.sys.desktop.sway.enable = lib.mkEnableOption "Sway";

  config = lib.mkIf cfg.enable (
    let
      gtk-theme = "Adwaita-Dark";
      icon-theme = "Adwaita";
      cursor-theme = "Adwaita";

      sway-dconf-settings = pkgs.writeTextFile {
        name = "sway-dconf-settings";
        destination = "/dconf/sway-custom";

        text = ''
          [org/gnome/desktop/interface]
          gtk-theme='${gtk-theme}'
          icon-theme='${icon-theme}'
          cursor-theme='${cursor-theme}'
        '';
      };

      # # NOTE: Replacing with systemd service
      # polkit-sway = pkgs.runCommand "polkit-sway" { preferLocalBuild = true; } ''
      #   mkdir -p "$out/etc/xdg/autostart"
      #   sed -e 's/^OnlyShowIn=.*$/OnlyShowIn=sway;/' ${pkgs.polkit_gnome}/etc/xdg/autostart/polkit-gnome-authentication-agent-1.desktop >$out/etc/xdg/autostart/polkit-sway-authentication-agent-1.desktop
      # '';

      sway-dconf-db = pkgs.runCommand "sway-dconf-db" { preferLocalBuild = true; } ''
        ${pkgs.dconf}/bin/dconf compile $out ${sway-dconf-settings}/dconf
      '';

      sway-dconf-profile = pkgs.writeText "sway-dconf-profile" ''
        user-db:user
        file-db:${sway-dconf-db}
      '';
    in
    {
      programs = {
        sway = {
          enable = true;

          wrapperFeatures.gtk = true;

          extraPackages = with pkgs; [
            # Theming
            gnome-themes-extra

            # Util
            grim
            imv
            jq
            kanshi
            mako
            pavucontrol
            playerctl
            qt5.qtwayland
            slurp
            swayidle
            swaylock-effects
            sway-contrib.grimshot
            sway-contrib.inactive-windows-transparency
            wf-recorder
            wl-clipboard
            wlogout
            wofi
          ];
        };

        # Force GTK settings via dconf
        dconf.profiles.sway = sway-dconf-profile;
        xwayland.enable = true;
        light.enable = true;
      };

      services.xserver.libinput = {
        enable = true;

        mouse.accelProfile = "flat";
      };

      ### Define compatibility variables
      # Some Programs don't use wayland by default and have to be told, so tell
      #  them.
      #
      environment.sessionVariables = {
        SDL_VIDEODRIVER = "wayland";
        QT_QPA_PLATFORM = "wayland-egl";
        WLR_NO_HARDWARE_CURSORS = "1";
        XDG_SESSION_TYPE = "wayland";
        DCONF_PROFILE = "sway";
      };

      xdg.portal = {
        enable = true;

        wlr = {
          enable = true;

          settings.screencast = {
            max_fps = 30;
            chooser_type = "simple";
            chooser_cmd = "${lib.getExe pkgs.slurp} -f %o -or";
          };
        };

        xdgOpenUsePortal = true;
      };

      gtk.iconCache.enable = true;

      qt = {
        enable = true;

        style = "adwaita-dark";
        platformTheme = "gnome";
      };

      ### Add a login manager
      # Provides greetd as a login manager
      #
      services.greetd = {
        enable = true;

        settings = {
          terminal.vt = 7;

          default_session.command = lib.concatStringsSep " " [
            "${pkgs.greetd.tuigreet}/bin/tuigreet"
            "--cmd \"${pkgs.sway}/bin/sway\""
            "--time"
            "--asterisks"
            "--remember"
          ];
        };
      };
    }
  );
}
