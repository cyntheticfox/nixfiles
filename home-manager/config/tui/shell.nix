{ config, pkgs, lib, ... }: {
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";

    shellAliases = {
      # Editor aliases
      "v" = config.home.sessionVariables.EDITOR;

      # List Aliases
      "l" = "ls";
      "ls" = "${pkgs.exa}/bin/exa --classify --color=always --icons";
      "la" = "ls --long --all --binary --group --header --git --color-scale";
      "tree" = "la --tree";

      # Standard program aliases
      "cat" = "${pkgs.bat}/bin/bat";
      "top" = "${pkgs.htop}/bin/htop";
      "ps" = "${pkgs.procs}/bin/procs";
      "more" = "less";
      "less" = config.home.sessionVariables.PAGER;

      # GCC and Clang coloring
      "gcc" = "gcc -fdiagnostics-color";
      "clang" = "clang -fcolor-diagnostics";

      # man page coloring
      "man" = lib.concatStringsSep " " [
        "LESS_TERMCAP_mb=$'\\e[01;31m'"
        "LESS_TERMCAP_md=$'\\e[01;34m'"
        "LESS_TERMCAP_me=$'\\e[0m'"
        "LESS_TERMCAP_se=$'\\e[0m'"
        "LESS_TERMCAP_so=$'\\e[01;31m'"
        "LESS_TERMCAP_ue=$'\\e[0m'"
        "LESS_TERMCAP_us=$'\\e[01;32m'"
        "man"
      ];

      # Nix flakes
      "n" = "nix";
      "nb" = "nix build";
      "nf" = "nix flake";
      "nfc" = "nix flake check";
      "nfi" = "nix flake init";
      "nfl" = "nix flake lock";
      "nfu" = "nix flake update";
      "nfsw" = "nixos-rebuild switch --flake . --use-remote-sudo";
      "nr" = "nix run";
      "ns" = "nix search";
      "nsn" = "nix search nixpkgs";
    };

    enableAutosuggestions = true;
    oh-my-zsh = {
      enable = true;

      plugins = [
        "aliases"
        "command-not-found"
        "docker"
        "encode64"
        "fd"
        "gh"
        "git"
        "git-auto-fetch"
        "git-extras"
        "git-flow"
        "git-lfs"
        "golang"
        "isodate"
        "python"
        "ripgrep"
        "rust"
        "systemd"
        "systemadmin"
        "tig"
        "terraform"
        "tmux"
        "urltools"
        "web-search"
      ];
    };

    plugins = [
      {
        name = "zsh-completions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-completions";
          rev = "0.33.0";
          sha256 = "sha256-cQSKjQhhOm3Rvnx9V6LAmtuPp/ht/O0IimpunoQlQW8=";
        };
      }
      {
        name = "fast-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zdharma-continuum";
          repo = "fast-syntax-highlighting";
          rev = "v1.55";
          sha256 = "sha256-DWVFBoICroKaKgByLmDEo4O+xo6eA8YO792g8t8R7kA=";
        };
      }
      {
        name = "history-search-multi-word";
        src = pkgs.fetchFromGitHub {
          owner = "zdharma-continuum";
          repo = "history-search-multi-word";
          rev = "5b44d8cea12351d91fbdc3697916556f59f14b8c";
          sha256 = "sha256-B+I53Y2E6dB2hqSc75FkYwzY4qAVMGzcNWu8ZXytIoc=";
        };
      }
      {
        name = "zsh-you-should-use";
        src = pkgs.fetchFromGitHub {
          owner = "MichaelAquilina";
          repo = "zsh-you-should-use";
          rev = "1.7.3";
          sha256 = "sha256-/uVFyplnlg9mETMi7myIndO6IG7Wr9M7xDFfY1pG5Lc=";
        };
      }
    ];

    history = {
      size = 102400;
      save = 10240;
      ignorePatterns = [
        "rm *"
        "pkill *"
        "cd *"
      ];
      expireDuplicatesFirst = true;
    };

    sessionVariables."ZSH_AUTOSUGGEST_USE_ASYNC" = "1";

    initExtraFirst = ''
      setopt AUTO_CD
      setopt PUSHD_IGNORE_DUPS
      setopt PUSHD_SILENT

      setopt ALWAYS_TO_END
      setopt AUTO_MENU
      setopt COMPLETE_IN_WORD
      setopt FLOW_CONTROL
    '';
  };

  programs.starship = {
    enable = true;

    settings = {
      add_newline = true;
      scan_timeout = 100;
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$shlvl"
        "$kubernetes"
        "$directory"
        "$git_branch"
        "$git_commit"
        "$git_state"
        "$git_status"
        "$hg_branch"
        "$docker_context"
        "$package"
        "$cmake"
        "$dart"
        "$dotnet"
        "$elixir"
        "$elm"
        "$erlang"
        "$golang"
        "$helm"
        "$java"
        "$julia"
        "$nim"
        "$nodejs"
        "$ocaml"
        "$perl"
        "$php"
        "$purescript"
        "$python"
        "$ruby"
        "$rust"
        "$swift"
        "$terraform"
        "$zig"
        "$nix_shell"
        "$conda"
        "$memory_usage"
        "$aws"
        "$gcloud"
        "$crystal"
        "$cmd_duration"
        "$custom"
        "$line_break"
        "$jobs"
        "$battery"
        "$time"
        "$status"
        "$shell"
        "$character"
      ];

      username = {
        format = "[$user]($style) in ";
        show_always = true;
        disabled = false;
      };

      hostname = {
        ssh_only = false;
        format = "⟨[$hostname](bold green)⟩ in ";
        disabled = false;
      };

      directory = {
        truncation_length = 3;
        fish_style_pwd_dir_length = 1;
      };

      shell = {
        disabled = false;
        bash_indicator = "bash";
        fish_indicator = "fish";
        powershell_indicator = "pwsh";
        elvish_indicator = "elvish";
        tcsh_indicator = "tcsh";
        xonsh_indicator = "xonsh";
        unknown_indicator = "?";
      };
    };
  };

  programs.direnv = {
    enable = true;

    nix-direnv = {
      enable = true;

      enableFlakes = true;
    };
  };

  programs.zoxide.enable = true;
}
