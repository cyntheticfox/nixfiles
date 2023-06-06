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
  programs.zsh.enable = true;

  sops.secrets = {
    cynthia-password = {
      sopsFile = ./secrets.yml;
      neededForUsers = true;
    };

    # gh-config = {
    #   inherit (config.users.users.cynthia) group;
    #
    #   sopsFile = ./secrets.yml;
    #   mode = "0400";
    #   owner = config.users.users.cynthia.name;
    #   path = "${config.users.users.cynthia.home}/.config/gh/hosts.yml";
    # };
  };

  users.users."cynthia" = {
    isNormalUser = true;
    home = "/home/cynthia";
    extraGroups = [ "wheel" ] ++ optGroups;
    uid = 1000;
    shell = config.home-manager.users.cynthia.zsh.package or pkgs.zsh;
    passwordFile = config.sops.secrets.cynthia-password.path;
  };
}
