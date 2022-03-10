{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    # ELF tools
    elf-dissector
    elf-header-real
    elfcat
    elfinfo
    elfkickers
    elfutils
    patchelf

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
