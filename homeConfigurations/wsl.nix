_: {
  imports = [
    ../home-manager/config/base.nix
    ../home-manager/config/tui/dev.nix
    ../home-manager/config/tui/documents.nix
    ../home-manager/config/tui/email.nix
    ../home-manager/config/tui/file.nix
    ../home-manager/config/tui/formatters.nix
    ../home-manager/config/tui/hacking.nix
    ../home-manager/config/tui/kubernetes.nix
    ../home-manager/config/tui/linters.nix
    ../home-manager/config/tui/lsp.nix
    ../home-manager/config/tui/networking.nix
    ../home-manager/config/tui/shells.nix
  ];

  home.stateVersion = "21.11";
}
