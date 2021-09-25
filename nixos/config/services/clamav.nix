{ config, pkgs, ... }: {
  services.clamav = {
    daemon.enable = true;
    updater = {
      enable = true;
      frequency = 24;
      interval = "hourly";
    };
  };
}
