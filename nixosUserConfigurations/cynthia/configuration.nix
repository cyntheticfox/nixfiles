{ config, pkgs, ... }: {
  programs.zsh.enable = true;

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
    shell = config.home-manager.users.cynthia.zsh.package or pkgs.zsh;
    passwordFile = config.sops.secrets.cynthia-password.path;
  };
}
