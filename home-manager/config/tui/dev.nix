{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    cargo
    cloc
    gcc_latest
    deno
    hexyl
    hyperfine
    openjdk
    jq
    libnotify
    nodejs_latest
    poetry
    python
    python3

    # Repository Management
    pre-commit
    git-secrets
  ];

  programs.gh = {
    enable = true;

    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
      pager = "less";
      editor = config.home.sessionVariables.EDITOR;
      aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
    };
  };
}
