# cups.nix
#
# CUPS Printing Daemon Configuration

{ config, ... }: {
  services.printing = {
    enable = true;
    browsing = false;
    startWhenNeeded = true;
    tempDir = "/tmp/cups";
    webInterface = false;
  };
}
