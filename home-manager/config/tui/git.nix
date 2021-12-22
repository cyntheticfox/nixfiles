{ config, pkgs, ... }: {
  programs.git = {
    enable = true;
    userName = "David Houston";
    userEmail = "houstdav000@gmail.com";
    aliases = {
      l = "log --abrev-commit --pretty=oneline";
      lg = "log --pretty=format:'%h %s' --graph";
      state = "status -sb --";
      unstage = "reset HEAD --";
    };
    signing = {
      key = "5960278CE235F821";
      signByDefault = true;
    };
    ignores = [
      # Vim backups/swaps
      "*~"
      ".*.swp"

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
        editor = "nvim";
        filemode = false;
        autocrlf = "input";
        hideDotFiles = true;
        ignoreCase = true;
      };

      init.defaultBranch = "main";
      pull.ff = "only";
    };
  };
}
