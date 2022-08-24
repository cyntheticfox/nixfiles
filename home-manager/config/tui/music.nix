{ config, pkgs, ... }: {
  home.packages = with pkgs; [ vimpc ];

  ### Add config file for vimpc
  # Strangely, the help documentation and manpage both state that the only file
  #   checked is at "~/.vimpcrc". I tried to get that to work, but it never
  #   loaded. Using `strace`, I found the only location it _ACTUALLY_ checks is
  #   "$XDG_CONFIG_HOME/vimpc/vimpcrc". Weird.
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

  services.mpd = {
    enable = true;
    musicDirectory = config.xdg.userDirs.music;
    playlistDirectory = "${config.services.mpd.musicDirectory}/_playlists";
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "PipeWire Sound Server"
      }
    '';
  };

  services.mpdris2 = {
    enable = true;
    notifications = true;
  };

  programs.beets = {
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
      directory = config.xdg.userDirs.music;
      library = "${config.xdg.dataHome}/beets/musiclibrary.db";
      import = {
        languages = "en jp";
        log = "${config.xdg.dataHome}/beets/import.log";
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
