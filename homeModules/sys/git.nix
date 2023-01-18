{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.sys.git;
in
{
  options.sys.git = {
    enable = mkEnableOption "Enable configuration of git environment";

    package = mkPackageOption pkgs "git" { };

    name = mkOption {
      type = types.str;
      description = ''
        User's full name to pass for Git commits.
      '';
    };

    email = mkOption {
      type = types.str;
      description = ''
        User's email address to pass for Git commits.
      '';
    };

    gpgkey = mkOption {
      type = types.str;
      description = ''
        User's GnuPG/PGP key to use for signing commits.
      '';
    };

    extraPackages = mkOption {
      type = with types; listOf package;
      default = with pkgs; [
        git-doc
        git-filter-repo
        git-ignore
        git-secrets
        gitflow
        octofetch
        onefetch
        sops
        tig
      ];
      description = ''
        Additional packages to install aside git.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = cfg.extraPackages;

    programs.git = {
      inherit (cfg) enable package;

      userName = cfg.name;
      userEmail = cfg.email;

      aliases = {
        l = "log --abrev-commit --pretty=oneline";
        lg = "log --pretty=format:'%h %s' --graph";
        state = "status -sb --";
        unstage = "reset HEAD --";
      };

      attributes = [ "*.pdf -text diff=pdf" ];

      signing = {
        key = cfg.gpgkey;
        signByDefault = true;
      };

      ignores = [
        # Vim backups/swaps
        "*~"
        "*.swp"

        # MacOS DS_Store
        ".DS_Store"

        # direnv
        ".envrc"
        ".direnv/"
      ];

      lfs.enable = true;
      delta.enable = true;

      extraConfig = {
        blame = {
          coloring = "highlightRecent";
          markUnblamableLines = true;
          markIgnoredLines = true;
        };

        core = {
          autocrlf = "input";
          editor = config.home.sessionVariables.EDITOR or "nano";
          filemode = false;
          hideDotFiles = true;
          ignoreCase = true;
          safecrlf = true;
        };

        credential.helper = "cache --timeout 600";
        fetch.output = "compact";

        help = {
          autocorrect = 20;
          format = "man";
        };

        init.defaultBranch = "main";
        merge.autoStash = true;
        pull.ff = "only";

        push = {
          autoSetupRemote = true;
          followTags = true;
          gpgSign = "if-asked";
        };

        rebase = {
          abbreviateCommands = true;
          autoStash = true;
          stat = true;
        };

        stash = {
          showPatch = true;
          showIncludeUntracked = true;
        };

        status = {
          branch = true;
          relativePaths = false;
        };

        tag = {
          forceSignAnnotated = true;
          gpgSign = true;
        };

        url."https://github.com".insteadOf = "git://github.com";

        user.useConfigOnly = true;
      };
    };
  };
}
