{ config, ... }: {
  services.printing.enable = true;

  hardware.printers.ensureDefaultPrinter = "Home-Printer";
  hardware.printers.ensurePrinters = [{
    description = "Brother HL-3170CDW";
    deviceUri = "ipp://192.168.5.11:631/ipp";
    model = "everywhere";
    name = "Home-Printer";
  }];
}
