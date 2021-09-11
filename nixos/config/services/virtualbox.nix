# virtualbox.nix
#
# Configuration and installation of virtualbox

{ config, pkgs, lib, ... }: {
  virtualisation.virtualbox.host = {
    enable = true;
    enableHardening = true;
  };
}
