{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.sys.core;
in
{
  options.sys.core = {
    enable = mkEnableOption "base configuration" // {
      default = true;
    };

    defaultPackages = mkOption {
      type = with types; listOf package;
      default = with pkgs; [
        file
        git
        curl
        coreutils
        bash
        gnupg
      ];
    };

    nix-experimental-features = mkOption {
      type =
        with types;
        listOf (enum [
          "auto-allocate-uids" # Added in 23.05
          "ca-derivations"
          "cgroup"
          "flakes"
          "nix-command"
          "repl-flake"
        ]);

      default = [
        "nix-command"
        "flakes"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    console = {
      font = "Lat2-Terminus16";
      useXkbConfig = true;
    };

    i18n.defaultLocale = "en_US.UTF-8";

    environment = {
      inherit (cfg) defaultPackages;

      etc."nix/nixpkgs-config.nix".text = lib.mkDefault ''
        {
          allowUnfree = ${lib.boolToString config.nixpkgs.config.allowUnfree};
        }
      '';

      homeBinInPath = true;
      localBinInPath = true;

      shellAliases = {
        ll = "ls -al";
        la = "ls -al";
      };
    };

    programs.vim.defaultEditor = true;

    networking.firewall.pingLimit = lib.mkIf config.networking.firewall.enable "1/minute";

    nix = {
      gc = {
        automatic = true;
        options = "--delete-older-than 7d";
        dates = "weekly";
        persistent = true;
      };

      optimise.automatic = true;

      settings = {
        allowed-users = [ "@wheel" ];
        auto-optimise-store = true;
        experimental-features = cfg.nix-experimental-features;

        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
        ];

        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };

    nixpkgs.config.allowUnfree = true;

    # Since apparently I can't trust people
    security.pki.caCertificateBlacklist = [
      ### Sites in countries I don't visit
      #
      "AC RAIZ FNMT-RCM SERVIDORES SEGUROS"
      "Autoridad de Certificacion Firmaprofesional CIF A62634068"

      # China Financial Certification Authority
      "CFCA EV ROOT"

      # Chunghwa Telecom Co., Ltd
      "ePKI Root Certification Authority"
      "HiPKI Root CA - G1"

      # Dhimyotis
      "Certigna"
      "Certigna Root CA"

      # GUANG DONG CERTIFICATE AUTHORITY
      "GDCA TrustAUTH R5 ROOT"

      # Hongkong Post
      "Hongkong Post Root CA 3"

      # iTrusChina Co.,Ltd.
      "vTrus ECC Root CA"
      "vTrus Root CA"

      # Krajowa Izba Rozliczeniowa S.A.
      "SZAFIR ROOT CA2"

      # NetLock Kft.
      "NetLock Arany (Class Gold) Főtanúsítvány"

      # TAIWAN-CA
      "TWCA Root Certification Authority"
      "TWCA Global Root CA"

      # Turkiye
      "TUBITAK Kamu SM SSL Kok Sertifikasi - Surum 1"
    ];

    services.logind = {
      extraConfig = ''
        IdleAction=lock
        IdleActionSec=0
      '';

      killUserProcesses = true;
      lidSwitch = "hybrid-sleep";
    };
  };
}
