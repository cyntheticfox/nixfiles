{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    # General binary tools
    bbe
    bintools
    bingrep
    bloaty
    bsdiff
    extrude
    pev
    poke

    # ELF tools
    chelf
    elf-dissector
    elf-header-real
    #elfcat
    elfinfo
    elfkickers
    elfutils
    elfx86exts
    patchelf
    statifier

    # C/General
    debugedit
    edb
    gdb
    lldb
    valgrind
    rr

    # Bash
    bashdb

    # Python
    pydb

    # Go
    delve

    # USB Devices
    hid-listen

    # RE/General
    apktool
    cutter
    ghidra
    radare2
    rehex
  ];
}
