{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.sys.core;
in
{
  options.sys.core = {
    enable = mkEnableOption "Enable core configuration packages" // { default = true; };

    packages = mkOption {
      type = with types; listOf package;
      default = with pkgs; [
        curlie
        dogdns
        gping
        procs
        traceroute
      ];
      description = ''
        Core user packages to install
      '';
    };

    extraPaths = mkOption {
      type = with types; listOf string;
      default = with pkgs; [
        "${config.home.homeDirectory}/.cargo/bin"
      ];
      description = ''
        Additional packages to add to the user's session path.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = cfg.packages;

    home.sessionPath = cfg.extraPaths;
  };
}
