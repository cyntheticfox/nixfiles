{ config, lib, pkgs, self, inputs, ... }: {
  nix = {
    allowedUsers = [ "@wheel" ];
    autoOptimiseStore = true;
    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    binaryCaches = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    extraOptions = ''
      experimental-features = nix-command flakes ca-derivations
    '';
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
      dates = "weekly";
      persistent = true;
    };
    optimise.automatic = true;
    registry = {
      dotfiles.flake = self;
      nixpkgs.flake = inputs.nixpkgs;
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

  networking = {
    useDHCP = false;
    firewall.pingLimit = lib.mkIf config.networking.firewall.enable "--limit 1/minute --limit-burst 5";
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  system.stateVersion = "22.05";
}
