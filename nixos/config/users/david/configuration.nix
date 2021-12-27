{ config, pkgs, lib, outputs, ... }: {
  sops.secrets = {
    david-password = {
      sopsFile = ./secrets.yml;
      neededForUsers = true;
    };

    gh-config = {
      inherit (config.users.users.david) group;

      sopsFile = ./secrets.yml;
      mode = "0440";
      owner = config.users.users.david.name;
      path = "${config.users.users.david.home}/.config/gh/hosts.yml";
    };
  };

  users.users."david" = {
    isNormalUser = true;
    home = "/home/david";
    extraGroups = [ "wheel" "networkmanager" "audio" ];
    uid = 1000;
    shell = pkgs.zsh;
    passwordFile = config.sops.secrets.david-password.path;
  };

  home-manager.users.david = outputs.nixosModules."${config.networking.hostName}";
}
