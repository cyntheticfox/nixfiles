{ config, pkgs, ... }: {
  home.packages = with pkgs; [ ncmpcpp ];

  services.mpd = {
    enable = true;
    musicDirectory = config.xdg.userDirs.music;
    playlistDirectory = "${config.services.mpd.musicDirectory}/_playlists";
    network.startWhenNeeded = true;
  };

  programs.beets = {
    enable = true;

    settings = {
      directory = config.xdg.userDirs.music;
      library = "${config.xdg.dataHome}/musiclibrary.db";
      import.move = "yes";
    };
  };
}
