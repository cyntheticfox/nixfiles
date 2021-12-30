{ pkgs, config, ... }: {
  home.packages = with pkgs; [
    teams
  ];

  xdg.mimeApps.defaultApplications."x-scheme-handler/msteams" = "teams.desktop";
}
