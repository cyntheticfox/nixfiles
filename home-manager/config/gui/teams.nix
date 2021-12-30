{ pkgs, config, lib, ... }: {
  home.packages = with pkgs; [
    teams
  ];

  xdg.mimeApps.defaultApplications."x-scheme-handler/msteams" = "teams.desktop";

  # For whatever reason, teams likes to overwrite the mimetypes, even if it's
  #   fine. So, add a step to activation to remove the file if it's not a link.
  #
  home.activation.remove-mimeapps = lib.hm.dag.entryBetween [ "writeBoundary" ] [ "checkLinkTargets" ] ''
    if [ ! -L ${config.xdg.configHome}/mimeapps.list ]; then
        $DRY_RUN_CMD rm $VERBOSE_ARG ${config.xdg.configHome}/mimeapps.list
    fi
  '';
}
