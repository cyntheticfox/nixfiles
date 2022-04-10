{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    lutris

    # Emulation
    flips
    retroarch

    # itch.io
    itch

    # Steam
    steam
    winetricks
    wine-wayland
    protontricks

    # Other games
    minecraft
  ];
}
