_: {
  imports = [
    ../../config/base.nix
    ../../config/tui/dev.nix
    ../../config/tui/documents.nix
    ../../config/tui/email.nix
    ../../config/tui/file.nix
    ../../config/tui/formatters.nix
    ../../config/tui/hacking.nix
    ../../config/tui/kubernetes.nix
    ../../config/tui/linters.nix
    ../../config/tui/lsp.nix
    ../../config/tui/networking.nix
    ../../config/tui/shells.nix
  ];

  home.stateVersion = "21.11";
}
