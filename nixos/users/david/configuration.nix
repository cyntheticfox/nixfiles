{ config, pkgs, lib, ... }:
let
  optionalGroup = { cond, group }: lib.optionalString cond group;

  optGroups = builtins.map optionalGroup [
    {
      cond = config.networking.networkmanager.enable;
      group = "networkmanager";
    }
    {
      cond = config.virtualisation.libvirtd.enable;
      group = "libvirtd";
    }
    {
      cond = config.virtualisation.kvmgt.enable;
      group = "kvmgt";
    }
    {
      cond = config.hardware.pulseaudio.systemWide;
      group = "audio";
    }
    {
      cond = config.services.jack.jackd.enable;
      group = "jackaudio";
    }
    {
      cond = config.hardware.acpilight.enable
        || config.hardware.brillo.enable
        || config.programs.light.enable;
      group = "video";
    }
    {
      cond = config.programs.adb.enable;
      group = "adbusers";
    }
    {
      cond = config.programs.wireshark.enable;
      group = "wireshark";
    }
    {
      cond = config.virtualisation.docker.enable;
      group = "docker";
    }
    {
      cond = config.virtualisation.podman.enable;
      group = "podman";
    }
  ];
in
{
  sops.secrets = {
    david-password = {
      sopsFile = ./secrets.yml;
      neededForUsers = true;
    };

    # gh-config = {
    #   inherit (config.users.users.david) group;
    #
    #   sopsFile = ./secrets.yml;
    #   mode = "0400";
    #   owner = config.users.users.david.name;
    #   path = "${config.users.users.david.home}/.config/gh/hosts.yml";
    # };
  };

  users.users."david" = {
    isNormalUser = true;
    home = "/home/david";
    extraGroups = [ "wheel" ] ++ optGroups;
    uid = 1000;
    shell = pkgs.zsh;
    passwordFile = config.sops.secrets.david-password.path;
  };
}
