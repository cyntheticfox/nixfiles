{ pkgs, config, ... }: {
  home.packages = with pkgs; [
    citrix_workspace
    teams
  ];
}
