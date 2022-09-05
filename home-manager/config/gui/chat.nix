{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    nixpkgs-master.discord
    nixpkgs-unstable.element-desktop
  ];

  home.sessionVariables."NIXOS_OZONE_WL" = 1;
}
