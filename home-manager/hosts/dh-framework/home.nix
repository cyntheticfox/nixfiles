{ config, pkgs, ... }: {
  imports = [
    ../../config/base.nix

    # Terminal modules
    ../../config/tui/cloud.nix
    ../../config/tui/dbg.nix
    ../../config/tui/dev.nix
    ../../config/tui/documents.nix
    ../../config/tui/rss.nix
  ];

  home.packages = with pkgs; [
    mozwire
  ];

  home.stateVersion = "21.11";
}
