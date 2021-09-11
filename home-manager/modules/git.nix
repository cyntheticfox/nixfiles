{ config, pkgs, ... }: {

  home.packages = with pkgs.gitAndTools; [
    git
    gitflow
    gh
  ];
}
