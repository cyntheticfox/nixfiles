{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    aircrack-ng
    exiftool
    foremost
    python38Packages.binwalk-full
    pwndbg
    pwntools
    radare2
  ];
}
