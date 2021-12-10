{ config, pkgs, dotfiles, ... }: {
  home.packages = with pkgs; [
    firefox-wayland
  ];

  programs.qutebrowser = {
    enable = true;
    loadAutoconfig = true;
    settings = {
      auto_save.session = true;
      colors.webpage.preferred_color_scheme = "dark";
      colors.webpage.darkmode.enabled = true;
      colors.webpage.darkmode.grayscale.images = 0.1;
      content.pdfjs = true;
      downloads.location.prompt = false;
      editor.command = [ "${pkgs.kitty}/bin/kitty" "-e" "vi" "{}" ];
      fonts = {
        default_family = "FiraMono Nerd Font";
        default_size = "10pt";
      };
      scrolling.smooth = true;
      tabs = {
        last_close = "close";
        title.format = "{audio}{current_title}";
      };
      window.title_format = "Qutebrowser - {perc}{private}{current_title}";
      zoom.default = "90%";
    };
  };
}
