{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    # Audio
    mpd
    ncmpcpp

    # Email
    neomutt

    # Web
    nyxt
    w3m

    # Extra Shells
    elvish
    mosh
    powershell
    xonsh
  ];
}
