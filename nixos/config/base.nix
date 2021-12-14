{ config, lib, pkgs, self, inputs, outputs, ... }: {
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
  };

  nix = {
    allowedUsers = [ "@wheel" ];
    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
    binaryCaches = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
    ];
    buildCores = 0;
    checkConfig = true;
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
      dates = "weekly";
      persistent = true;
    };
    maxJobs = "auto";
    nixPath = (lib.mapAttrsToList (name: value: name + "=" + value) inputs) ++ [ ("ospkgs=" + "../.") ("nixpkgs-overlays=" + ../. + "/overlays.nix") ];
    optimise.automatic = true;
    registry = (lib.mapAttrs (name: value: { flake = value; }) (lib.filterAttrs (name: value: value ? outputs) inputs)) // { ospkgs = { flake = self; }; };
    requireSignedBinaryCaches = true;
    useSandbox = true;
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = lib.attrValues outputs.overlays;
  };

  environment.systemPackages = with pkgs; [
    git gnupg neofetch
  ];

  system.stateVersion = "22.05";
}
