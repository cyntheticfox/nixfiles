{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    burpsuite
    mozillavpn
    wireshark
  ];
}
