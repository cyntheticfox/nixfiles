_: {
  imports = [
    ../home-manager/config/base.nix
    ../home-manager/config/base-desktop.nix
    ../home-manager/config/gui/chat.nix
    ../home-manager/config/tui/dev.nix
    ../home-manager/config/tui/documents.nix
    ../home-manager/config/tui/email.nix
    ../home-manager/config/tui/file.nix
  ];

  home.stateVersion = "20.09";
}
