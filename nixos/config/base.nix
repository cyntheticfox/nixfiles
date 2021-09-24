{ config, lib, pkgs, self, inputs, outputs, ... }: {
  home-manager.useUserPackages = true;

  nix = {
    allowedUsers = [ "@wheel" ];
    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
    binaryCaches = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org/"
      "https://nixpkgs-wayland.cachix.org/"
    ];
    buildCores = 0;
    checkConfig = true;
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes ca-references
    '';
    gc.automatic = true;
    maxJobs = "auto";
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    optimise.automatic = true;
    registry.nixpkgs.flake = inputs.nixpkgs;
    requireSignedBinaryCaches = true;
    useSandbox = true;
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "21.11";
}
