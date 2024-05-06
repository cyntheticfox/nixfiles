{ config, lib, ... }:
let
  cfg = config.sys.desktop.web;
in
{
  imports = [
    ./chromium.nix
    ./edge.nix
    ./firefox.nix
  ];

  options.sys.desktop.web = {
    defaultBrowser = lib.mkOption {
      type =
        with lib.types;
        nullOr (enum [
          "chromium"
          "edge"
          "firefox"
        ]);

      default = "firefox";
      description = "Browser to set as the default via desktop files.";
    };

    autostartDefault = lib.mkEnableOption "Default browser on startup" // {
      default = true;
    };
  };

  config = lib.mkIf (cfg.defaultBrowser != null) (
    let
      browserBin = lib.getExe config.programs.${cfg.defaultBrowser}.package;
      setFileAssociation = list: lib.genAttrs list (_: "${cfg.defaultBrowser}.desktop");
    in
    {
      home.sessionVariables."BROWSER" = browserBin;

      xdg.mimeApps.defaultApplications = setFileAssociation [
        "text/html"
        "text/xml"
        "application/xhtml+xml"
        "application/xml"
        "application/rdf+xml"
        "image/gif"
        "image/jpeg"
        "image/png"
        "x-scheme-handler/ftp"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];

      systemd.user.services.${cfg.defaultBrowser} = lib.mkIf cfg.autostartDefault {
        Unit = {
          Description = "${cfg.defaultBrowser} instance managed by Systemd";
          Requires = [ "graphical-session-pre.target" ];
        };

        Service = {
          Type = "exec";
          ExecStart = browserBin;
          Restart = "on-failure";
        };

        Install.WantedBy = [ "graphical-session.target" ];
      };
    }
  );
}
