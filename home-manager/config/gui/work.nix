{ pkgs, config, ... }: {
  home.packages = with pkgs; [
    teams
  ];
}
