{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    # Audio
    mpd
    ncmpcpp

    # Web
    nyxt

    # Extra Shells
    elvish
    fish
    mosh
    powershell
    xonsh
  ];
}
