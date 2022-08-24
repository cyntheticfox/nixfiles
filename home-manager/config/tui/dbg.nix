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
    radare2
    rehex
  ];
}
