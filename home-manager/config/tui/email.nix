{ config, pkgs, lib, ... }: {
  accounts.email.accounts.work = {
    notmuch.enable = true;
    offlineimap = {
      enable = true;
      postSyncHookCommand = ''
        ${pkgs.notmuch}/bin/notmuch --config=${config.xdg.configHome}/notmuch/notmuchrc -- new
      '';
    };
    msmtp.enable = true;
  };

  ### Add a system for indexing mail
  # Use the notmuch mail indexer for indexing and thus searching and tagging
  #   emails.
  #
  programs.notmuch = {
    enable = true;
    hooks = {
      postNew = ''
        ${pkgs.notmuch}/bin/notmuch tag +nixos -- tag:new and from:nixos1@discourcemail.com
      '';
    };
  };

  # For some reason, notmuch doesn't work if the base dir doesn't exist, and it
  #   doesn't automatically get created. It also doesn't like to work if you
  #   don't use its setup command, and so won't create the Xapian database.
  #
  home.activation.create-maildir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p $VERBOSE_ARG ${config.accounts.email.maildirBasePath}
    $DRY_RUN_CMD test -d ${config.accounts.email.maildirBasePath}/.notmuch/xapian
  '';

  ### Add a system for sending mail
  #
  programs.msmtp.enable = true;

  ### Add an IMAP synchronization system
  # Add a program and timers for synchronizing mail to and from the server with
  #  the IMAP protocol.
  #
  programs.offlineimap.enable = true;

  systemd.user.services.mail-sync =
  let
    configFile = "${config.xdg.configHome}/offlineimap/config";
  in {
    Unit = {
      Description = "offlineimap mail synchronization";
      ConditionPathExists = configFile;
    };

    Service = {
      Type = "oneshot";
      ExecStart = lib.concatStringsSep " " [
        "${pkgs.offlineimap}/bin/offlineimap"
        "-c ${configFile}"
      ];
    };
  };

  systemd.user.timers.mail-sync = {
    Unit.Description = "offlineimap mail synchronization";
    Timer = {
      OnCalendar = "*:0/15";
      Unit = "mail-sync.service";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
