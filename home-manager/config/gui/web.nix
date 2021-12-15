{ config, pkgs, lib, ... }:

let
  font = "FiraMono Nerd Font";
in
{
  home.sessionVariables."BROWSER" = "qutebrowser";

  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-wayland;
  };

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
        default_family = font;
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

  xdg.configFile."mimeapps.list".text = lib.mkDefault ''
    [Default Applications]
    text/html=org.qutebrowser.qutebrowser.desktop
    text/xml=org.qutebrowser.qutebrowser.desktop
    application/xhtml+xml=org.qutebrowser.qutebrowser.desktop
    application/xml=org.qutebrowser.qutebrowser.desktop
    application/rdf+xml=org.qutebrowser.qutebrowser.desktop
    image/gif=org.qutebrowser.qutebrowser.desktop
    image/jpeg=org.qutebrowser.qutebrowser.desktop
    image/png=org.qutebrowser.qutebrowser.desktop
    x-scheme-handler/http=org.qutebrowser.qutebrowser.desktop
    x-scheme-handler/https=org.qutebrowser.qutebrowser.desktop
  '';
}
