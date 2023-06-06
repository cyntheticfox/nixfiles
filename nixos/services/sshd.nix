_: {
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;

    allowSFTP = true;

    settings = {
      KbdInteractiveAuthentication = true;
      PasswordAuthentication = true;
      # ForwardX11 = false;
    };

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
  };
}
