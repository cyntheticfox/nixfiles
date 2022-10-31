{ pkgs, ... }: {
  home.packages = with pkgs; [
    audacity
    elisa
    lmms
    rhythmbox
    soundkonverter
  ];
}
