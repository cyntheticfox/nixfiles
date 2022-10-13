{ config, pkgs, lib, self, ... }:
let
  optNetworkManagerGroup =
    if
      config.networking.networkmanager.enable
    then
      "networkmanager"
    else
      "";
  optLibvirtdGroup =
    if
      config.virtualisation.libvirtd.enable
    then
      "libvirtd"
    else
      "";
  optKvmgtGroup =
    if
      config.virtualisation.kvmgt.enable
    then
      "kvmgt"
    else
      "";
  optAudioGroup =
    if
      config.hardware.pulseaudio.systemWide
    then
      "audio"
    else
      "";
  optJackaudioGroup =
    if
      config.services.jack.jackd.enable
    then
      "jackaudio"
    else
      "";
  optLightGroup =
    if
      config.hardware.acpilight.enable ||
      config.hardware.brillo.enable ||
      config.programs.light.enable
    then
      "video"
    else
      "";
  optAdbGroup =
    if
      config.programs.adb.enable
    then
      "adbusers"
    else
      "";
  optWiresharkGroup =
    if
      config.programs.wireshark.enable
    then
      "wireshark"
    else
      "";
  optGroups = [
    optNetworkManagerGroup
    optLibvirtdGroup
    optKvmgtGroup
    optAudioGroup
    optJackaudioGroup
    optLightGroup
  ];
in
{
  sops.secrets = {
    david-password = {
      sopsFile = ./secrets.yml;
      neededForUsers = true;
    };

    gh-config = {
      inherit (config.users.users.david) group;

      sopsFile = ./secrets.yml;
      mode = "0400";
      owner = config.users.users.david.name;
      path = "${config.users.users.david.home}/.config/gh/hosts.yml";
    };
  };

  users.users."david" = {
    isNormalUser = true;
    home = "/home/david";
    extraGroups = [ "wheel" ] ++ optGroups;
    uid = 1000;
    shell = pkgs.zsh;
    passwordFile = config.sops.secrets.david-password.path;
  };

  home-manager.users.david = import (../../../../. + "/home-manager/hosts/${config.networking.hostName}/home.nix");

  environment.persistence."/state".users.david = {
    directories = [
      { directory = ".aws"; mode = "0700"; }
      { directory = ".azure"; mode = "0700"; }
      ".config/dconf"
      ".config/discord"
      { directory = ".config/gcloud"; mode = "0700"; }
      ".config/Element"
      ".config/libvirt"
      ".config/Microsoft/Microsoft Teams"
      ".config/pipewire"
      ".config/teams"
      { directory = ".docker"; mode = "0700"; }
      { directory = ".gnupg"; mode = "0700"; }
      ".mozilla"
      { directory = ".ssh"; mode = "0700"; }
      "archive"
      "docs"
      "emu"
      "games"
      "music"
      "pics"
      "repos"
      "videos"
    ];

    files = [
      "wallpaper.png"
      "lockscreen.jpg"
      ".local/share/beets/musiclibrary.db"
      ".config/pavucontrol.ini"
    ];
  };

  environment.persistence."/persist".users.david = {
    directories = [
      ".cache/pre-commit"
      ".cache/fontconfig"
      ".cache/mesa_shader_cache"
      ".cache/virt-manager"
      ".cargo/registry"
      ".local/share/containers"
      ".local/share/direnv/allow"
      ".local/share/libvirt"
      ".local/share/mime"
      ".local/share/mpd"
      ".local/share/nvim/site"
      ".local/share/Steam"
      ".local/share/zoxide"
      ".local/state/wireplumber"
      ".minikube/cache"
      ".terraform.d"
      "dbg"
      "iso"
      "opt"
      "tmp"
    ];

    files = [
      ".local/share/beets/import.log"
      ".local/share/nix/trusted-settings.json"
      ".zsh_history"
    ];
  };
}
