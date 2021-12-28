{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    ffmpeg-full
    mpv
    openshot-qt
    obs-studio
    yt-dlp
  ];
}
