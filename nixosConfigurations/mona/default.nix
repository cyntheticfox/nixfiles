{ modulesPath, pkgs, ... }: {
  imports = [
    (modulesPath + "/virtualisation/linode-config.nix")
  ];

  networking = {
    hostName = "ashley";
    useDHCP = false;
    firewall = {
      enable = true;

      allowPing = true;
      allowedTCPPorts = [
        80
        443
        # 5432 # PostgreSQL
        # 31637 # Redis
        # 55000 # mastodon-streaming
        # 55001 # mastodon-web
        # 55002 # mastodon-sidekiq
      ];
    };
  };

  time.timeZone = "America/New_York";

  environment.systemPackages = with pkgs; [
    git
    gnupg
    htop
    neovim
  ];

  security.acme = {
    acceptTerms = true;

    defaults.email = "houstdav000@gmail.com";
  };

  services.mastodon = {
    enable = true;
    localDomain = "gh0st.network";

    configureNginx = true;
    smtp.fromAddress = "mastodon@gh0st.sh";
  };

  system.stateVersion = "22.05";
}
