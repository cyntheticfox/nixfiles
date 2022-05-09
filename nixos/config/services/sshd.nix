# ssh-configuration.nix
#
# Implement an SSH daemon for logging in remotely (only done in VM)

{ config, pkgs, lib, ... }: {
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    allowSFTP = true;
    passwordAuthentication = true;
    forwardX11 = false;
    hostKeys = [
      {
        bits = 4096;
        path = "/etc/ssh_host_rsa_key";
        type = "rsa";
      }
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
        rounds = 100;
      }
    ];
    openFirewall = true;
  } // (
    if
      config.system.stateVersion == "22.05"
    then
      {
        kbdInteractiveAuthentication = true;
      }
    else
      { }
  );
}
