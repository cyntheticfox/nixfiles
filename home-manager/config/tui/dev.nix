{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    ansible
    cargo
    cloc
    gcc_latest
    deno
    github-cli
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

  xdg.configFile."gh/config.yml".text = ''
    git_protocol: ssh
    prompt: enable
    pager: less
    aliases:
      co: pr checkout
  '';
}
