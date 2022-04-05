{ config, pkgs, lib, ... }:

let
  font = "FiraMono Nerd Font";
  homepage_url = "https://www.startpage.com/do/mypage.pl?prfe=ed8e0b7c6a6177ac1e11ccf45f0fbf02eda7eaea24fa3ca22ff3c5be22f5db78fb207ddd54bd6a552a601512394049130d39a57321213f59c677c2ddab0f2b3779ab65fe2e7d1a56920e52462f";

  primary-browser = {
    name = "firefox";
    bin = "${config.programs.firefox.package}/bin/firefox";
    xdg-desktop = "firefox.desktop";
  };
in
{
  home.sessionVariables.BROWSER = primary-browser.bin;

  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-wayland;
  };

  xdg.mimeApps.defaultApplications =
    let
      setFileAssociation = list: lib.genAttrs list (_: primary-browser.xdg-desktop);
    in
    setFileAssociation [
      "text/html"
      "text/xml"
      "application/xhtml+xml"
      "application/xml"
      "application/rdf+xml"
      "image/gif"
      "image/jpeg"
      "image/png"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
}
