{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    hexyl
    neovim
  ];
}
