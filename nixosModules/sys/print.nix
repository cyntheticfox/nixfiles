{ config, lib, pkgs, ... }:
let
  cfg = config.sys.print;
in
{
  options.sys.print.enable = lib.mkEnableOption "Printing";

  config = lib.mkIf cfg.enable {
    services.printing = {
      enable = true;

      drivers = with pkgs; [ canon-cups-ufr2 ];
    };

    hardware = {
      printers = {
        ensureDefaultPrinter = "Home-Printer";

        ensurePrinters = [{
          description = "Canon ImageCLASS MF642CDW";
          deviceUri = "ipp://192.168.2.7:631/ipp";
          model = "everywhere";
          name = "Home-Printer";
        }];
      };

      sane = {
        enable = true;

        extraBackends = with pkgs; [ sane-airscan ];
      };
    };
  };
}
