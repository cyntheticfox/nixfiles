{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    elvish
    fish
    mosh
    #powershell - Broken Package
    xonsh
  ];
}
