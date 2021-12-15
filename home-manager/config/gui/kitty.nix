{ config, pkgs, ... }: {
  programs.kitty = {
    enable = true;

    settings = {
      # Set font settings
      font_family = "FiraCodeNerdFontComplete-Retina";
      font_size = 11;
      font_features = "FiraCodeNerdFontComplete-Retina +zero +onum";

      # Set terminal bell to off
      enable_audio_bell = false;
      visual_bell_duration = 0;

      # Fix tab bar
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_bar_min_tabs  = 1;
      tab_title_template = "{index}: {title}";
      tab_bar_background = "#222";

      # Set background Opacity
      background_opacity = "0.9";
    };

    extraConfig = ''
      include ./nord.conf
    '';
  };

  xdg.configFile."kitty/nord.conf".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/connorholyday/nord-kitty/3a819c1f207cd2f98a6b7c7f9ebf1c60da91c9e9/nord.conf";
    sha256 = "sha256:1fbnc6r9mbqb6wxqqi9z8hjhfir44rqd6ynvbc49kn6gd8v707p1";
  };
}
