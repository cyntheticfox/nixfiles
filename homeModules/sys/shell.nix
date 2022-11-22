{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.sys.shell;
  posixGitFunctions = ''
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
in
{
  options.sys.shell = {
    enable = mkEnableOption "Enable shell management" // {
      default = true;
    };

    pager = mkOption {
      type = with types; nullOr str;
      default = "${pkgs.less}/bin/less";
      description = ''
        CLI pager to use for the user. This gets set to the PAGER env
        variable.
      '';
    };

    editor = mkOption {
      type = with types; nullOr str;
      default = "${pkgs.neovim}/bin/nvim";
      description = ''
        CLI editor to use for the user. This gets set to the EDITOR env
        variable.
      '';
    };

    viewer = mkOption {
      type = with types; nullOr str;
      default = "${pkgs.neovim}/bin/nvim -R";
      description = ''
        CLI file viewer to use for the user. This gets set to the VISUAL env
        variable.
      '';
    };

    aliases = mkOption {
      type = with types; attrsOf str;
      default = {
        "h" = "history";
        "pg" = "pgrep";

        # Editor aliases
        "v" = config.home.sessionVariables.EDITOR or "nano";

        # Make things human-readable
        "dd" = "dd status=progress";
        "df" = "df -Th";
        "du" = "du -h";
        "free" = "free -h";
        "pkill" = "pkill -e";

        # Additional git aliases
        "gcmsg" = "git commit --signoff -m";
        "gcmsga" = "git commit --signoff --all -m";
      };
      description = ''
        Aliases to add for the shell.
      '';
    };

    manageBashConfig = mkEnableOption "Enable default bash config" // { default = true; };
    manageBatConfig = mkEnableOption "Enable default bat config" // { default = true; };
    manageExaConfig = mkEnableOption "Enable default exa config" // { default = true; };
    manageLessConfig = mkEnableOption "Enable default less config" // { default = true; };
    manageTmuxConfig = mkEnableOption "Enable deafult tmux config" // { default = true; };
    manageStarshipConfig = mkEnableOption "Enable default starship config" // { default = true; };
    manageZshConfig = mkEnableOption "Enable default zsh config" // { default = true; };

    zoxide = mkEnableOption "Enable zoxide" // { default = true; };
    z-lua = mkEnableOption "Enable z-lua";
    autojump = mkEnableOption "Enable autojump";

    extraShells = mkOption {
      type = with types; nullOr (listOf package);
      default = with pkgs; [
        elvish
        powershell
      ];
    };
  };


  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = cfg.extraShells;
      home.shellAliases = cfg.aliases;
      home.sessionVariables = mkDefault {
        "PAGER" = cfg.pager;
        "EDITOR" = cfg.editor;
        "VISUAL" = cfg.viewer;
      };

      programs.autojump.enable = cfg.autojump;
      programs.z-lua.enable = cfg.z-lua;
      programs.zoxide.enable = cfg.zoxide;
    }
    (mkIf cfg.manageBashConfig {
      programs.bash = {
        enable = true;

        historyFile = "${config.xdg.dataHome}/bash/bash_history";
        historyControl = [ "ignoredups" "ignorespace" ];
        historyIgnore = [
          "cd"
          "exit"
          "pkill"
          "rm"
        ];

        initExtra = posixGitFunctions;
      };
    })
    (mkIf cfg.manageBatConfig {
      home.shellAliases."cat" = "bat";

      programs.bat = {
        enable = mkDefault true;

        config = mkDefault {
          theme = "base16";
          italic-text = "always";
          style = "full";
        };
      };
    })
    (mkIf cfg.manageExaConfig {
      home.shellAliases = {
        "l" = "exa --classify --color=always --icons";
        "ls" = "exa --classify --color=always --icons";
        "la" = "exa --classify --color=always --icons --long --all --binary --group --header --git --color-scale";
        "ll" = "exa --classify --color=always --icons --long --all --binary --group --header --git --color-scale";
        "tree" = "exa --classify --color=always --icons --long --all --binary --group --header --git --color-scale --tree";
      };

      programs.exa = {
        enable = mkDefault true;
      };
    })
    (mkIf cfg.manageLessConfig {
      home.shellAliases."more" = "less";

      # TODO: Figure out a lesskey config
      programs.less.enable = true;
    })
    (mkIf cfg.manageStarshipConfig {
      programs.starship = {
        enable = mkDefault true;

        package = mkDefault pkgs.starship;

        settings = mkDefault {
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
    })
    (mkIf cfg.manageTmuxConfig {
      programs.tmux = mkIf cfg.manageTmuxConfig {
        enable = mkDefault true;
        clock24 = mkDefault true;
        keyMode = mkDefault "vi";
        prefix = mkDefault "C-a";
        shell = mkDefault "${pkgs.zsh}/bin/zsh";
        plugins = with pkgs.tmuxPlugins; mkDefault [
          cpu
          prefix-highlight
          resurrect
        ];

        extraConfig = mkDefault ''
          # Configure looks
          set -g status on
          set -g status-fg 'colour15'
          set -g status-bg 'colour8'
          set -g status-left-length '100'
          set -g status-right-length '100'
          set -g status-position 'top'
          set -g status-left '#[fg=colour15,bold] #S '
          set -g status-right '#[fg=colour0,bg=colour8]#[fg=colour6,bg=colour0] %Y-%m-%d %H:%M '
          set-window-option -g status-fg 'colour15'
          set-window-option -g status-bg 'colour8'
          set-window-option -g window-status-separator ''''''
          set-window-option -g window-status-format '#[fg=colour15,bg=colour8] #I #W '
          set-window-option -g window-status-current-format '#[fg=colour8,bg=colour4]#[fg=colour0] #I  #W #[fg=colour4,bg=colour8]'
        '';
      };
    })
    (mkIf cfg.manageZshConfig {
      programs.zsh = {
        enable = mkDefault true;
        dotDir = ".config/zsh";

        shellGlobalAliases = {
          "UUID" = "$(uuidgen | tr -d \\n)";
        };

        defaultKeymap = "viins";

        initExtra = posixGitFunctions;

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
          path = "${config.xdg.dataHome}/zsh/zsh_history";
          size = 102400;
          save = 1024000;

          ignorePatterns = [
            "cd *"
            "exit *"
            "rm *"
            "pkill *"
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
          setopt PRINT_EXIT_VALUE
          setopt C_BASES

          # Additional History Options
          setopt INC_APPEND_HISTORY
          setopt HIST_IGNORE_ALL_DUPS
          setopt HIST_NO_STORE
          setopt HIST_REDUCE_BLANKS
          setopt HIST_VERIFY
        '';
      };
    })
  ]);
}
