_: {
  imports = [
    ../home-manager/config/base.nix
  ];

  sys = {
    core = {
      enable = true;

      manageFilePackages.enable = true;
      manageNetworkPackages.enable = true;
      manageProcessPackages.enable = true;
    };

    dev.enable = true;
    shell.enable = true;
  };
}
