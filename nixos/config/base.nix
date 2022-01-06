{ config, lib, pkgs, self, inputs, outputs, ... }: {
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    sharedModules = [
      ({ pkgs, ... }: {
        programs.nix-index.enable = true;

        systemd.user = {
          services.nix-index = {
            Unit.Description = "Update nix-index cache";

            Service = {
              Type = "oneshot";
              ExecStart = "${pkgs.nix-index}/bin/nix-index";
            };
          };

          timers.nix-index = {
            Install.WantedBy = [ "timers.target" ];

            Unit.Description = "Update nix-index cache";

            Timer = {
              OnCalendar = "weekly";
              Persistent = true;
            };
          };
        };
      })
    ];
  };

  nix = {
    allowedUsers = [ "@wheel" ];
    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "foosteros.cachix.org-1:rrDalTfOT1YohJXiMv8upgN+mFLKZp7eWW1+OGbPRww="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    binaryCaches = [
      "https://cache.nixos.org"
      "https://foosteros.cachix.org"
      "https://nix-community.cachix.org"
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

  environment.etc."nix/nixpkgs-config.nix".text = lib.mkDefault ''
    {
      allowUnfree = ${lib.boolToString config.nixpkgs.config.allowUnfree};
    }
  '';

  environment = {
    defaultPackages = with pkgs; [
      bc
      file
      tree
      unzip
      cachix
      git
      gnupg
      neofetch
      nix-index
      nix-alien
      progress
      strace
    ];

    homeBinInPath = true;
    localBinInPath = true;
  };

  networking.useDHCP = false;

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  system.stateVersion = "22.05";
}
