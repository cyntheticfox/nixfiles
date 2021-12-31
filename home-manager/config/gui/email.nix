{ config, pkgs, lib, ... }: {
  imports = [ ./../tui/email.nix ];
  accounts.email.accounts.work.astroid.enable = true;

  programs.astroid = {
    enable = true;
    externalEditor =
    if
      config.home.sessionVariables.EDITOR_GRAPHICAL == "nvim-qt"
    then
      lib.concatStringsSep " " [
        "${config.home.sessionVariables.EDITOR_GRAPHICAL}"
        "--"
        "-c "
        (lib.escapeShellArgs [
          "set ft=mail"
          "+set fileencoding=utf-8"
          "+set ff=unix"
          "+set fo+=w"
        ])
        "%1"
      ]
    else
      "";
    pollScript = "${pkgs.offlineimap}/bin/offlineimap";
    extraConfig.poll.interval = 0;
  };
}
