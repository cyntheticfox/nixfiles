{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sys.desktop.web.chromium;
in
{
  options.sys.desktop.web.chromium = {
    enable = lib.mkEnableOption "Chromium";
    package = lib.mkPackageOption pkgs "chromium" { };
  };

  config = lib.mkIf cfg.enable { home.packages = [ cfg.package ]; };
}
