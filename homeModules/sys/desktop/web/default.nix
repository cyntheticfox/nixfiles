{ config, lib, pkgs, ... }@args:
let
  cfg = config.sys.desktop.web;
in
lib.recursiveUpdate
{
  options.sys.desktop.web = {
    defaultBrowser = lib.mkOption {
      type = with lib.types; nullOr (enum [ "chromium" "firefox" ]);
      default = "firefox";
      description = "Browser to set as the default via desktop files.";
    };

    autostartDefault = lib.mkEnableOption "Default browser on startup" // { default = true; };
  };

  config = lib.mkIf ((config.sys.desktop.chromium.enable || config.sys.desktop.web.firefox.enable) && cfg.defaultBrowser != null) (
    let
      browserBin = lib.getExe config.programs.${cfg.defaultBrowser}.package;
      setFileAssociation = list: lib.genAttrs list (_: "${cfg.defaultBrowser}.desktop");
    in
    {
      home.sessionVariables.BROWSER = browserBin;

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
          ExitType = "cgroup";
          ExecStart = browserBin;
          Restart = "on-abort";
        };

        Install.WantedBy = [ "graphical-session.target" ];
      };
    }
  );
}
  (import ./firefox.nix (args // { inherit pkgs; })) # FIXME: A Very dumb deadnix workaround
