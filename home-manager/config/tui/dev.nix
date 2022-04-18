{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    cargo
    cloc
    gcc_latest
    deno
    hexyl
    htmlq
    hyperfine
    jq
    nodejs_latest
    pastel
    poetry
    python
    python3

    # Repository Management
    pre-commit
    git-secrets
  ];

  programs.java = {
    enable = true;
    package = pkgs.openjdk;
  };

  programs.gh = {
    enable = true;

    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
      pager = config.home.sessionVariables.PAGER;
      editor = config.home.sessionVariables.EDITOR;
      aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
    };
  };
}
