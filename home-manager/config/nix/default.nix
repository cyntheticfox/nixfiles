{ config, pkgs, ... }: {
  # Helper DBs
  home.packages = with pkgs; [
    nixos-unstable.comma
  ];

  programs.nix-index.enable = true;

  # Nix itself
  nix.registry = import ./registry.nix;

  # Nixpkgs
  nixpkgs.config = import ./nixpkgs.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs.nix;

  # NOTE: Fish supports `&&` and `||` as of v3.0.0
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
}
