{ pkgs, ... }: {
  home.packages = with pkgs; [
    lutris

    # Emulation
    flips
    retroarchFull

    # itch.io
    itch

    # Steam
    steam
    winetricks
    nixpkgs-unstable.wine-wayland
    protontricks

    # Other games
    minecraft
    nixpkgs-unstable.prismlauncher
  ];
}
