{ config, lib, ... }:
let
  cfg = config.sys.print;

  ippConfig = lib.types.submodule (hostName: {
    uri = lib.mkOption {
      types = lib.types.str;
      default = "ipp://${hostName}.${config.networking.domain}:631/ipp";

      description = ''
        URI to print to with IPP Everywhere.
      '';
    };
  });

  paperPrinter = lib.types.submodule (_: {
    hostName = lib.mkOption {
      type = lib.types.str;

      description = ''
        Paper printing device hostname.
      '';
    };

    description = lib.mkOption {
      type = lib.types.lines;

      description = ''
        Description of paper printing device.
      '';
    };

    printDrivers = lib.mkOption {
      type = with lib.types; listOf package;

      description = ''
        Packages required to install print device.
      '';
    };

    config = lib.mkOption {
      type = lib.types.oneOf [ ippConfig ];

      description = ''
        Configuration for the printer.
      '';
    };
  });

  # paperScanner = lib.types.submodule (_: {
  #   hostName = lib.mkOption {
  #     type = lib.types.str;
  #
  #     description = ''
  #       Paper scanning device hostname.
  #     '';
  #   };
  # });

  # myPrinters = [
  #   (
  #     let
  #       hostName = "cyn-print";
  #     in
  #     {
  #       inherit hostName;
  #
  #       description = "Canon ImageCLASS MF642CDW";
  #
  #       config = ippConfig hostName;
  #
  #       printDrivers = with pkgs; [ canon-cups-ufr2 ];
  #     }
  #   )
  # ];
  #
  # myScanDrivers = with pkgs; [ sane-airscan ];
in
{
  options.sys.iot = {
    paperPrint = {
      enable = lib.mkEnableOption "paper document printing";

      printers = lib.mkOption {
        type = with lib.types; listOf paperPrinter;
        default = [ ];

        description = ''
          Ordered list of printers to configure for the system.
        '';
      };
    };

    paperScan = {
      enable = lib.mkEnableOption "paper document scanning";

      scanDrivers = lib.mkOption {
        type = with lib.types; listOf package;
        default = [ ];

        description = ''
          Additional packages to install to support scanners.
        '';
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.paperPrint.enable {

      services.printing = {
        inherit (cfg.paperPrint) enable;

        drivers = builtins.zipWithAttrs (builtins.getAttr "printDrivers") cfg.paperPrint.printers;
      };

      hardware.printers =
        let
          printHost = "cyn-print";
        in
        {
          ensureDefaultPrinter = builtins.elemAt 0 cfg.paperPrint.printers;

          ensurePrinters = [{
            description = "Canon ImageCLASS MF642CDW";
            deviceUri = "ipp://${printHost}.${config.networking.domain}:631/ipp";
            model = "everywhere";
            name = "cyn-print";
          }];
        };
    })
    (lib.mkIf cfg.paperScan.enable {
      services.avahi = { inherit (cfg.paperScan) enable; };

      hardware.sane = {
        inherit (cfg.paperScan) enable;

        extraBackends = cfg.paperScan.scanDrivers;
      };
    })
  ];
}
