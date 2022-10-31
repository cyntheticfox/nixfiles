{ pkgs, ... }: {
  home.packages = with pkgs; [
    powershell
  ];

  # NOTE: Fish supports `&&` and `||` as of v3.0.0
  home.shellAliases = {
    # Additional git aliases
    "gcmsg" = "git commit --signoff -m";
    "gcmsga" = "git commit --signoff --all -m";
  };

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";

    shellGlobalAliases."UUID" = "$(uuidgen | tr -d \\n)";

    defaultKeymap = "viins";

    initExtra = ''
      function gcmsgap() {
        git commit --signoff --all -m $@ && git push
      }

      function gcmsgapf() {
        git commit --signoff --all -m $@ && git push --force-with-lease
      }

      function gcmsgapf!() {
        git commit --signoff --all -m $@ && git push --force
      }

      function gcmsgp() {
        git commit --signoff -m $@ && git push
      }

      function gcmsgpf() {
        git commit --signoff -m $@ && git push --force-with-lease
      }

      function gcmsgpf!() {
        git commit --signoff -m $@ && git push --force
      }
    '';

    enableAutosuggestions = true;
    oh-my-zsh = {
      enable = true;

      plugins = [
        "aliases"
        "aws"
        "colored-man-pages"
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
}
