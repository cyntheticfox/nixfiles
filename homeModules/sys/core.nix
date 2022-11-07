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

    manageXDGConfig = mkEnableOption "Enable xdg dirs management" // { default = true; };
  };

  config = mkIf cfg.enable {
    home.packages = cfg.packages;

    home.sessionPath = cfg.extraPaths;

    xdg = mkIf cfg.manageXDGConfig {
      enable = mkDefault true;
      cacheHome = mkDefault "${config.home.homeDirectory}/.cache";
      configHome = mkDefault "${config.home.homeDirectory}/.config";
      dataHome = mkDefault "${config.home.homeDirectory}/.local/share";
      stateHome = mkDefault "${config.home.homeDirectory}/.local/state";

      userDirs = {
        enable = mkDefault true;

        createDirectories = mkDefault true;

        desktop = mkDefault "${config.home.homeDirectory}";
        documents = mkDefault "${config.home.homeDirectory}/docs";
        download = mkDefault "${config.home.homeDirectory}/tmp";
        music = mkDefault "${config.home.homeDirectory}/music";
        pictures = mkDefault "${config.home.homeDirectory}/pics";
        publicShare = mkDefault "${config.home.homeDirectory}/public";
        templates = mkDefault "${config.home.homeDirectory}/.templates";
        videos = mkDefault "${config.home.homeDirectory}/videos";

        extraConfig.XDG_SECRETS_DIR = mkDefault "${config.home.homeDirectory}/.secrets";
      };
    };
  };
}
