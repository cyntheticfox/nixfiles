{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.sys.music;
in
{
  options.sys.music = {
    enable = mkEnableOption "Enable music players and controls";

    desktopPackages = mkOption {
      type = with types; listOf package;

      default = with pkgs; [
        audacity
        elisa
        lmms
        soundkonverter
      ];

      description = ''
        What desktop music packages to install. Typically includes both editors and players.
      '';
    };
  };

  config = mkIf cfg.enable (
    let
      musicDir = config.xdg.userDirs.music or "$XDG_MUSIC_DIR";
    in
    {
      home.packages = with pkgs; [
        mpc-cli
        vimpc
      ] ++ cfg.desktopPackages;

      ### Add config file for vimpc
      # Strangely, the help documentation and manpage both state that the only file
      #   checked is at "~/.vimpcrc". I tried to get that to work, but it never
      #   loaded. Using `strace`, I found the only location it _ACTUALLY_ checks is
      #   "$XDG_CONFIG_HOME/vimpc/vimpcrc". Weird.
      #
      # TODO: Convert to own module
      #
      xdg.configFile."vimpc/vimpcrc".text = ''
        " Set the default window to show at startup
        set window library
        set windows library,lists,playlist

        set albumartist
        set autoscroll
        set groupignorethe
        set incsearch
        set mouse
        set reconnect
        set seekbar
        set singlequit
        set smartcase

        map J :tabprevious<C-M>
        map K :tabnext<C-M>
      '';

      # # TODO: Fix or watch https://github.com/MusicPlayerDaemon/MPD/issues/773
      # services.mpd = {
      #   enable = true;
      #
      #   musicDirectory = musicDir;
      #   playlistDirectory = "${config.services.mpd.musicDirectory}/_playlists";
      #   extraConfig = ''
      #     audio_output {
      #       type "pipewire"
      #       name "PipeWire Sound Server"
      #     }
      #   '';
      # };

      services.mopidy = {
        enable = true;

        extensionPackages = with pkgs; [
          mopidy-local
          mopidy-mpd
          mopidy-mpris
          mopidy-musicbox-webclient
          # mopidy-notify
        ];

        settings = {
          core.restore_state = true;

          # Built-in extensions
          file.enabled = true;
          http = {
            enabled = true;

            hostname = "::1";
          };

          # External extensions
          local.media_dir = musicDir;
          mpd.hostname = "::1";
        };
      };

      # services.mpdris2 = {
      #   enable = true;
      #
      #   notifications = true;
      #   musicDirectory = musicDir;
      # };

      programs.beets =
        let
          beetsStateDir = "${config.xdg.dataHome or "$XDG_DATA_HOME"}/beets";
        in
        {
          enable = true;

          settings = {
            match = {
              required = "title artist";

              ignored_media = [
                "Data CD"
                "DVD"
                "DVD-Video"
                "Blu-ray"
                "HD-DVD"
                "VCD"
                "SVCD"
                "UMD"
                "VHS"
              ];
            };

            directory = musicDir;
            library = "${beetsStateDir}/musiclibrary.db";

            import = {
              languages = "en jp";
              log = "${beetsStateDir}/import.log";
              move = true;
            };

            format_item = "$albumartist - $album - $track $title";

            paths = {
              default = "$albumartist - $album%aunique{}/$track - $title";
              singleton = "etc/$artist - $title";
              comp = "Various Artists - $album%aunique{}/$track - $title ($artist)";
            };
          };
        };
    }
  );
}
