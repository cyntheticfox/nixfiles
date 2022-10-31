{ pkgs, ... }:
let
  theme = "nord";
  themeFile = "${theme}.conf";
in
{
  home.sessionVariables.TERMINAL = "${pkgs.kitty}/bin/kitty";

  programs.kitty = {
    enable = true;

    settings = {
      # Set font settings
      font_family = "FiraCodeNerdFontCompleteMono-Retina";
      font_size = 12;
      font_features = "FiraCodeNerdFontCompleteMono-Retina +zero +onum";

      # Set terminal bell to off
      enable_audio_bell = false;
      visual_bell_duration = 0;

      # Fix tab bar
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_bar_min_tabs = 1;
      tab_title_template = "{index}: {title}";
      tab_bar_background = "#222";

      # Set background Opacity
      background_opacity = "0.9";
    };

    extraConfig = ''
      include ./${themeFile}
    '';
  };

  xdg.configFile."kitty/${themeFile}".source =
    let
      owner = "connorholyday";
      repo = "nord-kitty";
      rev = "3a819c1f207cd2f98a6b7c7f9ebf1c60da91c9e9";
      sha256 = "sha256:1fbnc6r9mbqb6wxqqi9z8hjhfir44rqd6ynvbc49kn6gd8v707p1";
    in
    pkgs.fetchurl {
      inherit sha256;

      url = "https://raw.githubusercontent.com/${owner}/${repo}/${rev}/${themeFile}";
    };
}
