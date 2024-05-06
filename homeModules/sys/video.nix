{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.sys.video;

  packageModule =
    {
      package,
      name,
      extraOptions ? { },
      defaultEnable ? false,
    }:
    types.submodule (_: {
      options = {
        enable = mkEnableOption "Enable ${name} configuration" // {
          default = defaultEnable;
        };

        package = mkPackageOption pkgs package { };
      } // extraOptions;
    });
in
{
  options.sys.video = {
    ffmpeg = mkOption {
      type = packageModule {
        package = "ffmpeg-full";
        name = "FFMpeg";
      };

      default = { };
    };

    mpv = mkOption {
      type = packageModule {
        package = "mpv";
        name = "mpv";
      };

      default = { };
    };
  };

  config = mkMerge [
    (mkIf cfg.ffmpeg.enable { home.packages = [ cfg.ffmpeg.package ]; })

    (mkIf cfg.mpv.enable { home.packages = [ cfg.mpv.package ]; })
  ];
}
