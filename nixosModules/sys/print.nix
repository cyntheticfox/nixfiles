{ config, lib, pkgs, ... }:
let
  cfg = config.sys.print;
in
{
  options.sys.print.enable = lib.mkEnableOption "paper document printing and scanning";

  config = lib.mkIf cfg.enable {
    services.avahi.enable = true;

    services.printing = {
      enable = true;

      drivers = with pkgs; [ canon-cups-ufr2 ];
    };

    hardware = {
      printers = {
        ensureDefaultPrinter = "cyn-print";

        ensurePrinters = [{
          description = "Canon ImageCLASS MF642CDW";
          deviceUri = "ipp://192.168.2.7:631/ipp";
          model = "everywhere";
          name = "cyn-print";
        }];
      };

      sane = {
        enable = true;

        extraBackends = with pkgs; [ sane-airscan ];
      };
    };
  };
}
