{ pkgs, config, lib, ... }: {
  home.packages = with pkgs; [
    nixos-unstable.teams
  ];

  xdg.mimeApps.defaultApplications."x-scheme-handler/msteams" = "teams.desktop";

  # For whatever reason, teams likes to overwrite the mimetypes, even if it's
  #   fine. So, add a step to activation to remove the file if it's not a link.
  #
  home.activation.remove-mimeapps =
    let
      filename = "${config.xdg.configHome}/mimeapps.list";
    in
    lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      if [ -e ${filename} ]; then
        if [ ! -L ${filename} ]; then
          $DRY_RUN_CMD rm $VERBOSE_ARG ${filename}
        fi
      fi
    '';
}
