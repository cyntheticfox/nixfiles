{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.sys.git;
in
{
  options.sys.git = {
    enable = lib.mkEnableOption "Enable configuration of git environment";

    package = lib.mkPackageOption pkgs "git" { };

    name = lib.mkOption {
      type = lib.types.str;

      description = ''
        User's full name to pass for Git commits.
      '';
    };

    email = lib.mkOption {
      type = lib.types.str;

      description = ''
        User's email address to pass for Git commits.
      '';
    };

    gpgkey = lib.mkOption {
      type = lib.types.str;

      description = ''
        User's GnuPG/PGP key to use for signing commits.
      '';
    };

    extraPackages = lib.mkOption {
      type = with lib.types; listOf package;

      default = with pkgs; [
        git-crypt
        git-doc
        git-filter-repo
        git-ignore
        git-secrets
        gitflow
        octofetch
        onefetch
        pre-commit
        sops
        tig
      ];

      description = ''
        Additional packages to install aside git.
      '';
    };

    shellAliases = lib.mkOption {
      type = with lib.types; attrsOf str;

      default = {
        # Some of the really good ones from OhMyZsh
        "g" = "git";
        "ga" = "git add";
        "gaa" = "git add --all";
        "gbl" = "git blame";
        "gb" = "git branch";
        "gba" = "git branch --all";
        "gbd" = "git branch --delete";
        "gp" = "git push";
        "gl" = "git pull";
        "glum" = "git pull upstream main"; # TODO: Make helper func for main branch
        "gluc" = "git pull upstream HEAD"; # TODO: Make helper func for current branch
        "gm" = "git merge";
        "gma" = "git merge --abort";
        "gms" = "git merge --squash";
        "gam" = "git am";
        "gap" = "git apply";
        "gbs" = "git bisect";
        "gco" = "git checkout";
        "gcb" = "git checkout -b";
        "gcp" = "git cherry-pick";
        "gsw" = "git switch";
        "gswm" = "git switch main"; # TODO: Add helper function
        "gswc" = "git switch --create";
        "gc" = "git commit --verbose";
        "gc!" = "git commit --verbose --amend";
        "gca" = "git commit --verbose --all";
        "gca!" = "git commit --verbose --all --amend";
        "gcl" = "git clone --recurse-submodules";
        "gd" = "git diff";
        "gds" = "git diff --staged";
        "gdup" = "git diff @{upstream}";
        "gf" = "git fetch";
        "gfa" = "git fetch --all --prune";
        "ghh" = "git help";
        "gpf" = "git push --verbose --force-with-lease --force-if-includes";
        "grb" = "git rebase";
        "grba" = "git rebase --abort";
        "grbc" = "git rebase --continue";
        "grbi" = "git rebase --interactive";
        "grbm" = "git rebase main"; # TODO: Make use helper func
        "grbom" = "git rebase origin/main"; # TODO: Make use helper func
        "grf" = "git reflog";
        "gr" = "git remote";
        "gra" = "git remote add";
        "grrm" = "git remote remove";
        "grmv" = "git remote rename";
        "grset" = "git remote set-url";
        "grh" = "git reset";
        "grhh" = "git reset --hard";
        "grhk" = "git reset --keep";
        "grhs" = "git reset --soft";
        "grs" = "git restore";
        "grev" = "git revert";
        "grm" = "git rm";
        "gsh" = "git show --pretty=short --show-signature";
        "gsta" = "git stash push";
        "gstaa" = "git stash apply";
        "gstd" = "git stash drop";
        "gstl" = "git stash list";
        "gst" = "git status";
        "gss" = "git status --short";
        "gsb" = "git status --short --branch";
        "gts" = "git tag --sign";

        # Modified
        "glgg" = "git log --graph --decorate --all";
        "glg" = "git log --stat";
        "grt" = "git rev-parse --show-toplevel";
        "gcmsg" = "git commit --verbose --signoff --message";

        # Extras
        "gi" = "git ignore";
        "gfd" = "git ls-files | fd";
        "gtsm" = "git tag --sign --modified";
      };
    };

    fishFunctions = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = {
        "gcmsgp" = "git commit -m $argv; and git push";
        "gcmsgpf" = "git commit -m $argv; and git push --force-with-lease";
        "gcmsgpf!" = "git commit -m $argv; and git push --force";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      inherit (cfg) shellAliases;

      packages = cfg.extraPackages;
    };

    programs.fish.functions = cfg.fishFunctions;

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
          editor = config.home.sessionVariables.EDITOR;
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
