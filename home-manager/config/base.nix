{ config, pkgs, ... }: {

  home.stateVersion = "20.09";

  nixpkgs.config.allowUnfree = true;

  # Enable home-manager
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    bashInteractive_5
    exa
    htop
    libtool
    neofetch
    p7zip
    zellij
    w3m
  ];
}
