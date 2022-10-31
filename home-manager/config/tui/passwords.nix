{ pkgs, ... }: {
  home.packages = with pkgs; [ pinentry ];
  programs.rbw.enable = true;
}
