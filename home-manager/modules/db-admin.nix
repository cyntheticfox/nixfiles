{ pkgs, config, ... }: {
  home.packages = with pkgs; [
    pgmanage
    mysql-workbench
  ];
}
