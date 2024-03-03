{ config, pkgs, ... }: {
  programs.fish.enable = true;

  sops.secrets.cynthia-password = {
    sopsFile = ./secrets.yml;
    neededForUsers = true;
  };

  users.users."cynthia" = {
    isNormalUser = true;
    home = "/home/cynthia";

    extraGroups = [
      "adbusers" # Android Debug
      "audio" # Pulseaudio
      "kvmgt"
      "libvirtd"
      "lp" # For scanning
      "podman"
      "scanner"
      "video" # Graphics mgmt
      "wheel" # Admin
      "wireshark"
    ];

    uid = 1000;
    shell = config.home-manager.users.cynthia.fish.package or pkgs.fish;
    hashedPasswordFile = config.sops.secrets.cynthia-password.path;
  };
}
