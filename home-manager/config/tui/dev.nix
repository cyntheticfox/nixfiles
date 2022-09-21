{ config, pkgs, ... }: {
  home.shellAliases = {
    "gcc" = "gcc -fdiagnostics-color";
    "clang" = "clang -fcolor-diagnostics";
  };

  home.packages = with pkgs; [
    act
    cargo
    cloc
    deno
    gcc_latest
    hexyl
    htmlq
    hyperfine
    jq
    (nixpkgs-unstable.llvmPackages_latest.clang.overrideAttrs (attrs: {
      meta.priority = gcc_latest.meta.priority + 1;
    }))
    nixpkgs-unstable.llvmPackages_latest.clang-manpages
    nodejs_latest
    pastel
    poetry
    python3

    # Repository Management
    pre-commit
    git-secrets
  ];

  programs.direnv = {
    enable = true;

    nix-direnv.enable = true;
  };

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
