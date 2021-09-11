{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    # GUI-Less
    aircrack-ng
    exiftool
    foremost
    python38Packages.binwalk-full
    pwndbg
    pwntools
    radare2

    # GUI Tools
    burpsuite
    ghidra-bin
    radare2-cutter
    wireshark
  ];
}
