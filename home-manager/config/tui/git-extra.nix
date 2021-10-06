{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    github-cli
    onefetch
  ];
}
