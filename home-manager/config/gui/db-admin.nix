{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    #mysql-workbench - Broken package
    pgmanage
  ];
}
