{ config, ... }: {
  services.printing = {
    enable = true;
    browsing = false;
    startWhenNeeded = true;
  };
}
