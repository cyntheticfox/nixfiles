{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.sys.core;
in
{
  options.sys.core = {
    enable = mkEnableOption "Enable core configuration packages" // { default = true; };

    packages = mkOption {
      type = with types; listOf package;
      default = with pkgs; [
        curlie
        dogdns
        gping
        procs
        traceroute
      ];
      description = ''
        Core user packages to install
      '';
    };

    extraPaths = mkOption {
      type = with types; listOf string;
      default = with pkgs; [
        "${config.home.homeDirectory}/.cargo/bin"
      ];
      description = ''
        Additional packages to add to the user's session path.
      '';
    };

    manageXDGConfig = mkEnableOption "Enable xdg dirs management" // { default = true; };

    manageNixConfig = mkEnableOption "Enable Nix config management" // { default = true; };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = cfg.packages;
      home.sessionPath = cfg.extraPaths;
    }
    (mkIf cfg.manageNixConfig
      {
        home.packages = with pkgs; [ nixos-unstable.comma ];
        home.shellAliases = {
          ### Nix Aliases
          # TODO: Make this a separate like OMZ module?
          #
          "n" = "nix";

          "nb" = "nix build";
          "nbr" = "nix build --rebuild";

          "nd" = "nix develop";

          "nf" = "nix flake";
          "nfc" = "nix flake check";
          "nfcl" = "nix flake clone";
          "nfi" = "nix flake init";
          "nfl" = "nix flake lock";
          "nfm" = "nix flake metadata";
          "nfs" = "nix flake show";
          "nfu" = "nix flake update";
          "nfuc" = "nix flake update && nix flake check";

          "nfmt" = "nix fmt";

          "nlog" = "nix log";

          "nos" = "nixos-rebuild";
          "nosb" = "nixos-rebuild build";
          "nosbo" = "nixos-rebuild boot";
          "nose" = "nixos-rebuild edit";
          "nossw" = "nixos-rebuild switch --use-remote-sudo";
          "nosswf" = "nixos-rebuild switch --use-remote-sudo --flake .";
          "nosswfc" = "nix flake check && nixos-rebuild switch --use-remote-sudo --flake .";
          "nosswfuc" = "nix flake update && nix flake check && nixos-rebuild switch --use-remote-sudo --flake .";
          "nosswrb" = "nixos-rebuild switch --use-remote-sudo --rollback";
          "nost" = "nixos-rebuild test";
          "nosv" = "nixos-rebuild build-vm";
          "nosvb" = "nixos-rebuild build-vm-with-bootloader";

          "np" = "nix profile";
          "nph" = "nix profile history";
          "npi" = "nix profile install";
          "npl" = "nix profile list";
          "npu" = "nix profile upgrade";
          "nprm" = "nix profile remove";
          "nprb" = "nix profile rollback";
          "npw" = "nix profile wipe-history";

          "nr" = "nix run";

          "nrepl" = "nix repl";

          "nreg" = "nix registry";
          "nregls" = "nix registry list";

          "ns" = "nix search";
          "nsn" = "nix search nixpkgs";
          "nsm" = "nix search nixpkgs-master";
          "nsu" = "nix search nixpkgs-unstable";

          "nsh" = "nix shell";
          "nshn" = "nix shell nixpkgs";

          "nst" = "nix store";
        };

        nix.registry = mkDefault {
          ### Nixpkgs
          #
          nixpkgs-master.to = {
            type = "github";
            owner = "NixOS";
            repo = "nixpkgs";
            ref = "master";
          };

          nixpkgs-staging.to = {
            type = "github";
            owner = "NixOS";
            repo = "nixpkgs";
            ref = "staging";
          };

          nixpkgs-unstable.to = {
            type = "github";
            owner = "NixOS";
            repo = "nixpkgs";
            ref = "nixpkgs-unstable";
          };

          nixos-unstable.to = {
            type = "github";
            owner = "NixOS";
            repo = "nixpkgs";
            ref = "nixos-unstable";
          };

          # TODO: Make dynamic
          nixos-stable.to = {
            type = "github";
            owner = "NixOS";
            repo = "nixpkgs";
            ref = "nixos-20.05";
          };

          # TODO: Make dynamic
          nixpkgs-stable.to = {
            type = "github";
            owner = "NixOS";
            repo = "nixpkgs";
            ref = "release-20.05";
          };

          ### Other people's configs
          #
          foosteros.to = {
            type = "github";
            owner = "lilyinstarlight";
            repo = "foosteros";
          };

          ### Build tools
          #
          naersk.to = {
            type = "github";
            owner = "nix-community";
            repo = "naersk";
          };

          napalm.to = {
            type = "github";
            owner = "nix-community";
            repo = "napalm";
          };

          node2nix.to = {
            type = "github";
            owner = "svanderburg";
            repo = "node2nix";
          };

          pre-commit-nix.to = {
            type = "github";
            owner = "cachix";
            repo = "pre-commit.nix";
          };
        };

        nixpkgs.config.allowUnfree = mkDefault true;

        programs.nix-index.enable = mkDefault true;
      })
    (mkIf cfg.manageXDGConfig {
      xdg = {
        enable = mkDefault true;
        cacheHome = mkDefault "${config.home.homeDirectory}/.cache";
        configHome = mkDefault "${config.home.homeDirectory}/.config";
        dataHome = mkDefault "${config.home.homeDirectory}/.local/share";
        stateHome = mkDefault "${config.home.homeDirectory}/.local/state";

        userDirs = {
          enable = mkDefault true;

          createDirectories = mkDefault true;

          desktop = mkDefault "${config.home.homeDirectory}";
          documents = mkDefault "${config.home.homeDirectory}/docs";
          download = mkDefault "${config.home.homeDirectory}/tmp";
          music = mkDefault "${config.home.homeDirectory}/music";
          pictures = mkDefault "${config.home.homeDirectory}/pics";
          publicShare = mkDefault "${config.home.homeDirectory}/public";
          templates = mkDefault "${config.home.homeDirectory}/.templates";
          videos = mkDefault "${config.home.homeDirectory}/videos";

          extraConfig = mkDefault {
            "XDG_SECRETS_DIR" = "${config.home.homeDirectory}/.secrets";
          };
        };
      };
    })
  ]);
}
