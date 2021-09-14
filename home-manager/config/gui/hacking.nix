{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    burpsuite
    ghidra-bin
    radare2-cutter
    wireshark
  ];
}
