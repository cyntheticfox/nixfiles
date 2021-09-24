{ config, pkgs, ... }: {
  imports = [
    ../../config/base.nix
    ../../config/base-desktop.nix
    ../../config/gui/chat.nix
    ../../config/gui/db-admin.nix
    ../../config/gui/dev.nix
    ../../config/gui/documents.nix
    ../../config/gui/email.nix
    ../../config/gui/fonts.nix
    ../../config/gui/games.nix
    ../../config/gui/libvirt.nix
    ../../config/gui/music.nix
    ../../config/gui/terminals.nix
    ../../config/gui/video.nix
    ../../config/gui/web.nix
    ../../config/gui/work.nix
    ../../config/tui/audio.nix
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
    ../../config/tui/web.nix
  ];

  home.stateVersion = "20.09";
}
