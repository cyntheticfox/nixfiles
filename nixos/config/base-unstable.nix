{ config, lib, pkgs, self, inputs, outputs, ... }: {
  nix = {
    checkConfig = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
      dates = "weekly";
      persistent = true;
    };
    # nixPath = (lib.mapAttrsToList (n: v: n + "=" + v) inputs) ++ [ ("ospkgs=" + "../.") ("nixpkgs-overlays=" + ../. + "/overlays.nix") ];
    optimise.automatic = true;
    registry = lib.mapAttrs (_: flake: { inherit flake; }) (lib.filterAttrs (_: v: v ? outputs) inputs);
    settings = {
      allowed-users = [ "@wheel" ];
      cores = 0;
      max-jobs = "auto";
      require-sigs = true;
      sandbox = true;
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

  environment.etc."nix/nixpkgs-config.nix".text = lib.mkDefault ''
    {
      allowUnfree = ${lib.boolToString config.nixpkgs.config.allowUnfree};
    }
  '';

  environment = {
    defaultPackages = with pkgs; [
      aria
      bc
      cachix
      file
      git
      gnupg
      nix-index
      neofetch
      progress
      strace
      tree
      unzip
    ];

    homeBinInPath = true;
    localBinInPath = true;
  };

  programs.vim.defaultEditor = true;

  programs.tmux.enable = true;

  programs.mtr.enable = true;

  networking.useDHCP = false;

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  system.stateVersion = "22.05";
}
