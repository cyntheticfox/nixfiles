{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    audacity
    elisa
    hyperchroma
    lmms
    rhythmbox
    soundkonverter
  ];
}
