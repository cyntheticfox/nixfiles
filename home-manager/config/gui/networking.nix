{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    nixos-unstable.burpsuite
    mozillavpn
    wireshark
  ];
}
