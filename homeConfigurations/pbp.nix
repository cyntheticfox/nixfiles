_: {
  imports = [
    ../home-manager/config/base.nix
    ../home-manager/config/base-desktop.nix
    ../home-manager/config/gui/chat.nix
    ../home-manager/config/tui/documents.nix
    ../home-manager/config/tui/email.nix
    ../home-manager/config/tui/file.nix
  ];

  sys = {
    dev.enable = true;
    fonts.enable = true;
    shell.enable = true;
  };
}
