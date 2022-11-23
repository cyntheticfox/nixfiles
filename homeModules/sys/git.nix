{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.sys.git;
in
{
  options.sys.git = {
    enable = mkEnableOption "Enable configuration of git environment";

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
        git-extras
        git-filter-repo
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
      enable = true;

      userName = cfg.name;
      userEmail = cfg.email;

      aliases = {
        l = "log --abrev-commit --pretty=oneline";
        lg = "log --pretty=format:'%h %s' --graph";
        state = "status -sb --";
        unstage = "reset HEAD --";
      };

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
        credential.helper = "cache --timeout 600";
        help.autocorrect = true;
        core = {
          editor = config.home.sessionVariables.EDITOR or "nano";
          filemode = false;
          autocrlf = "input";
          hideDotFiles = true;
          ignoreCase = true;
        };

        url."https://github.com".insteadOf = "git://github.com";

        init.defaultBranch = "main";
        pull.ff = "only";
        tag.gpgSign = true;
      };
    };
  };
}
