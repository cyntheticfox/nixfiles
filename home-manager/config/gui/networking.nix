{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    burpsuite
    mozilavpn
    wireshark
  ];
}
