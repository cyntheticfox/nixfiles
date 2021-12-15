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

  xdg.mimeApps.defaultApplications =
  let
    quteBrowser = "org.qutebrowser.qutebrowser.desktop";
  in {
    "text/html" = quteBrowser;
    "text/xml" = quteBrowser;
    "application/xhtml+xml" = quteBrowser;
    "application/xml" = quteBrowser;
    "application/rdf+xml" = quteBrowser;
    "image/gif" = quteBrowser;
    "image/jpeg" = quteBrowser;
    "image/png" = quteBrowser;
    "x-scheme-handler/http" = quteBrowser;
    "x-scheme-handler/https" = quteBrowser;
  };
}
