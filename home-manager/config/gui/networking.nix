{ pkgs, ... }: {
  home.packages = with pkgs; [
    nixpkgs-unstable.burpsuite
    mozillavpn
    wireshark
  ];
}
