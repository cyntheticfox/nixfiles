_: {
  imports = [
    ../home-manager/config/gui/chat.nix
  ];

  sys = {
    dev.enable = true;
    desktop = {
      enable = true;

      defaultBroswer = "firefox";
    };
    fonts.enable = true;
    podman.enable = true;

    shell.enable = true;
  };
}
