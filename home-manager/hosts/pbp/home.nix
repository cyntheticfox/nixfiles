{ config, pkgs, ... }: {
  imports = [
    ../../config/base.nix
    ../../config/base-desktop.nix
    ../../config/gui/chat.nix
    ../../config/tui/dev.nix
    ../../config/tui/documents.nix
    ../../config/tui/email.nix
    ../../config/tui/file.nix
  ];

  home.stateVersion = "20.09";
}
