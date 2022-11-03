{ config, lib, pkgs, self, ... }:
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

  home-manager.users.david = self.lib.personalNixosHMConfig { inherit lib; inherit (config.networking) hostName; inherit (self.outputs) homeModules; };

  environment.persistence."/state".users.david = {
    directories = [
      {
        directory = ".aws";
        mode = "0700";
      }
      {
        directory = ".azure";
        mode = "0700";
      }
      ".config/dconf"
      ".config/discord"
      {
        directory = ".config/gcloud";
        mode = "0700";
      }
      ".config/Element"
      ".config/libvirt"
      ".config/Microsoft/Microsoft Teams"
      ".config/pipewire"
      ".config/teams"
      {
        directory = ".docker";
        mode = "0700";
      }
      {
        directory = ".gnupg";
        mode = "0700";
      }
      ".mozilla"
      {
        directory = ".ssh";
        mode = "0700";
      }
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
      ".local/share/PrismLauncher"
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
