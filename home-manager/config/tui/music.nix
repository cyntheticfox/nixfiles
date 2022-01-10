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
      directory = config.xdg.userDirs.music;
      library = "${config.xdg.dataHome}/musiclibrary.db";
      import.move = "yes";
      paths = {
        default = "$albumartist - $album%aunique{}/$track $title";
        singleton = "Non-Album/$artist - $title";
        comp = "Compilations/$album%aunique{}/$track $title";
      };
    };
  };
}
