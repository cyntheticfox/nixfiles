{ config, pkgs, ... }: {
  home-manager = {
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

    useGlobalPkgs = true;
    useUserPackages = true;
  };
}

