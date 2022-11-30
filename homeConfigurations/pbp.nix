_: {
  imports = [
    ../home-manager/config/base-desktop.nix
    ../home-manager/config/gui/chat.nix
  ];

  sys = {
    dev.enable = true;
    fonts.enable = true;
    podman.enable = true;

    shell.enable = true;
  };
}
