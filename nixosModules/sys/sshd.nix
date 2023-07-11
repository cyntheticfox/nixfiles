{ config, lib, ... }:
let
  cfg = config.sys.sshd;
in
{
  options.sys.sshd = {
    enable = lib.mkEnableOption "SSH daemon";

    openFirewall = lib.mkEnableOption "ssh firewall exception";
  };

  config = lib.mkIf cfg.enable {
    # Enable the OpenSSH daemon.
    services.openssh = {
      inherit (cfg) enable openFirewall;

      hostKeys = [
        {
          bits = 4096;
          openSSHFormat = true;
          path = "/etc/ssh_host_rsa_key";
          rounds = 100;
          type = "rsa";
        }
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          rounds = 100;
          type = "ed25519";
        }
      ];
    };
  };
}
