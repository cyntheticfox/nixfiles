{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    kitty
  ];

  xdg.configFile = {
    "kitty/kitty.conf".text = ''
      # Include style file
      include aura-theme.conf

      # Set font settings
      font_family FiraCodeNerdFontComplete-Retina
      font_size 11.0
      font_features FiraCodeNerdFontComplete-Retina +zero +onum

      # Set terminal bell to off
      enable_audio_bell no
      visual_bell_duration 0.0

      # Fix tab bar
      tab_bar_edge top
      tab_bar_style powerline
      tab_bar_min_tabs 1
      tab_title_template "{index}: {title}"
      tab_bar_background #222

      # Set background Opacity
      background_opacity 0.9
    '';

    "kitty/aura-theme.conf".source = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/daltonmenezes/aura-theme/main/packages/kitty/aura-theme.conf";
      sha256 = "03c8c9e1bf283bf8380379183f39168c45a05c3fd4b22ab54c156675d8e519f1";
    };
  };
}
