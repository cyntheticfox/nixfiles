{ config, pkgs, lib, ... }:

let
  font = "FiraMono Nerd Font";
in
{
  home.sessionVariables.BROWSER = "${config.programs.qutebrowser.package}/bin/qutebrowser";

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
      colors.webpage = {
        preferred_color_scheme = "dark";
        darkmode = {
          enabled = true;
          grayscale.images = 0.1;
        };
      };
      content = {
        cookies.accept = "no-3rdparty";
        default_encoding = "utf-8";
        headers.do_not_track = true;
        pdfjs = true;
      };
      downloads = {
        location = {
          directory = config.xdg.userDirs.download;
          prompt = false;
        };

        open_dispatcher = "${pkgs.xdg_utils}/bin/xdg-open";
        remove_finished = 60 * 1000; # 60 seconds * 1000 ms per second
      };
      editor.command = [ config.home.sessionVariables.EDITOR_GRAPHICAL "--" "{}" ];
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
    in
    {
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
