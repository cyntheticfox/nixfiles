{ pkgs, lib, ... }: {
  services.clamav = {
    daemon = {
      enable = true;
      settings = {
        LogFile = "/var/log/clamd.log";
        LogTime = true;
        VirusEvent = lib.escapeShellArgs [
          "${pkgs.libnotify}/bin/notify-send"
          "--"
          "ClamAV Virus Scan"
          "Found virus: %v"
        ];
        DetectPUA = true;
      };
    };
    updater = {
      enable = true;
      frequency = 24;
      interval = "hourly";
    };
  };

  systemd =
    let
      description = "Run ClamAV Virus Scan";
      documentation = [ "man(1):clamscan" ];
    in
    {
      services.clamav-scan = {
        inherit description documentation;

        script = "${pkgs.clamav}/bin/clamscan -i -r -- /home";
        serviceConfig = {
          Type = "oneshot";
        };
      };

      timers.clamav-scan = {
        inherit description documentation;

        wantedBy = [ "timers.target" ];

        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
        };
      };
    };
}
