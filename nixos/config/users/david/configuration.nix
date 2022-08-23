{ config, pkgs, lib, outputs, ... }: {
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
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "docker" "podman" "kvm" "libvirtd" ];
    uid = 1000;
    shell = pkgs.zsh;
    passwordFile = config.sops.secrets.david-password.path;
  };

  home-manager.users.david = outputs.nixosModules."${config.networking.hostName}";

  environment.persistence."/state".users.david = {
    directories = [
      { directory = ".aws"; mode = "0700"; }
      { directory = ".azure"; mode = "0700"; }
      ".config/dconf"
      ".config/discord"
      ".config/Element"
      ".config/libvirt"
      ".config/Microsoft/Microsoft Teams"
      ".config/pipewire"
      ".config/teams"
      { directory = ".docker"; mode = "0700"; }
      { directory = ".gnupg"; mode = "0700"; }
      ".mozilla"
      { directory = ".ssh"; mode = "0700"; }
      "docs"
      "emu"
      "music"
      "pics"
      "repos"
      "videos"
    ];

    files = [
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
      ".local/share/mime"
      ".local/share/mpd"
      ".local/share/nvim/site"
      ".local/share/Steam"
      ".local/state/wireplumber"
      ".minikube/cache"
      ".terraform.d"
      "iso"
      "opt"
      "tmp"
    ];

    files = [
      ".config/mimeapps.list"
      ".local/share/zoxide/db.zo"
      ".local/share/nix/trusted-settings.json"
      ".zsh_history"
    ];
  };
}
