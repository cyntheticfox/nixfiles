{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    # General binary tools
    bintools
    bingrep
    bloaty

    # C/General
    gdb
    lldb
    valgrind
    rr

    # RE/General
    cutter
    ghidra
    radare2
    rehex
  ];
}
