{ config, pkgs, lib, ... }: {
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";

    shellAliases = {
      # Editor aliases
      "v" = "${pkgs.neovim}/bin/nvim";

      # List Aliases
      "l" = "ls";
      "ls" = "${pkgs.exa}/bin/exa -F --color=always --icons";
      "la" = "ls -abghl";

      # Standard program aliases
      "cat" = "${pkgs.bat}/bin/bat";
      "top" = "${pkgs.htop}/bin/htop";
      "ps" = "${pkgs.procs}/bin/procs";

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
      "nfsw" = "sudo nixos-rebuild switch --flake .";
      "nr" = "nix run";
      "ns" = "nix search";
      "nsn" = "nix search nixpkgs";
    };

    enableAutosuggestions = true;
    defaultKeymap = "viins";

    oh-my-zsh = {
      enable = true;

      plugins = [
        "cargo"
        "command-not-found"
        "git"
        "git-flow"
        "git-lfs"
        "golang"
        "python"
        "systemadmin"
        "terraform"
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
      ];
      expireDuplicatesFirst = true;
    };

    sessionVariables = {
      "ZSH_AUTOSUGGEST_USE_ASYNC" = "1";
      "ZSH_AUTOSUGGEST_HISTORY_IGNORE" = "cd *";
    };

    initExtraFirst = ''
      setopt AUTO_CD
      setopt PUSHD_IGNORE_DUPS
      setopt PUSHD_SILENT

      setopt ALWAYS_TO_END
      setopt AUTO_MENU
      setopt COMPLETE_IN_WORD
      setopt FLOW_CONTROL
      '';

    initExtra = ''
      function __is_git_repository() {
          git rev-parse --git-dir >/dev/null 2>&1

          return "$?"
      }

      function __msg_not_valid_repository() {
          echo "($1): Current directory is not a valid Git repository."
      }

      function __clone_func() {
          echo "📦 Remote repository: $1"
          git clone $1
      }

      function __hosting_clone_func() {
          local HOST_USERNAME=""
          local HOST_URL=""

          HOST_USERNAME=$(git config --global --get "user.$1")

          if [[ $# -gt 1 ]]; then
              if [[ $# -eq 2 ]]; then
                  if [[ "$2" =~ ^[a-zA-Z0-9\-]+$ ]]; then
                      HOST_URL="$1:$HOST_USERNAME/$2.git"
                  else
                      HOST_URL= "$1:$2.git"
                  fi
              else
                  HOST_URL="$1:$2/$3.git"
              fi

              __clone_func "$HOST_URL"
          else
              echo "Repository name is required!"
              echo "Example: $1 your-repo-name"
              echo
              echo "Usages:"
              echo "  a) $1 username/repo-name"
              echo "  b) $1 username repo-name"
              echo "  c) $1 repo-name"
              echo "     For this, it's necessary to set your $1 username (login)"
              echo "     in your global config first, like:"
              echo "     git config --global user.$1 \"your-username\""
              echo
              echo "     You will also need to set your ssh config for $1 to use"
              echo "     any of these."
              echo
          fi
      }

      function push() {
          if __is_git_repository; then
              git push "$@"
          else
              __msg_not_valid_repository "push"
          fi
      }

      function pull() {
          if __is_git_repository; then
              git pull "$@"
          else
              __msg_not_valid_repository "pull"
          fi
      }

      function commit() {
          if __is_git_repository; then
              git commit --signoff "$@"
          else
              __msg_not_valid_repository "commit"
          fi
      }

      function commit-all() {
          if __is_git_repository; then
              git commit -a --signoff "$@"
          else
              __msg_not_valid_repository "commit-all"
          fi
      }

      function switch() {
          if __is_git_repository; then
              git switch "$@"
          else
              __msg_not_valid_repository "switch"
          fi
      }

      function stash() {
          if __is_git_repository; then
              git stash "$@"
          else
              __msg_not_valid_repository "stash"
          fi
      }

      function rebase() {
          if __is_git_repository; then
              git rebase '$@'
          else
              __msg_not_valid_repository "rebase"
          fi
      }

      function stage() {
          if __is_git_repository; then
              git add .
          else
              __msg_not_valid_repository "stage"
          fi
      }

      function unstage() {
          if __is_git_repository; then
              git unstage
          else
              __msg_not_valid_repository "unstage"
          fi
      }

      function state() {
          if __is_git_repository; then
              git state
          else
              __msg_not_valid_repository "state"
          fi
      }

      function github() {
          __hosting_clone_func "github" $@
      }

      function gitlab() {
          __hosting_clone_func "gitlab" $@
      }

      function bitbucket() {
          __hosting_clone_func "bitbucket" $@
      }

# Create Functions for NixOS
      function nixupd() {
          if command -v nixos-rebuild &>/dev/null; then
              sudo nix-channel --update "$@"
          else
              nix-channel --update "$@"
          fi
      }

      function nixsw() {
          if command -v nixos-rebuild &>/dev/null; then
              sudo nixos-rebuild switch "$@"
          else
              home-manager switch "$@"
          fi
      }
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
        "$env_var"
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

      env_var = {
        style = "white bold";
        format = "[$env_value]($style) ";
        variable = "STARSHIP_SHELL";
        default = "?";
      };
    };

    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  programs.z-lua = {
    enable = true;
    enableZshIntegration = true;
    enableAliases = true;
  };

  programs.less.enable = true;
  programs.lesspipe.enable = true;
}
