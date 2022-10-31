{ pkgs, ... }: {
  home.packages = with pkgs; [
    ghidra
    jd-gui
  ];
}
