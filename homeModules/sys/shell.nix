{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.sys.shell;

  posixGitFunctions = ''
    function gcmsgp() {
      git commit --message $@ && git push
    }

    function gcmsgpf() {
      git commit --message $@ && git push --force-with-lease --force-if-includes
    }
  '';
in
{
  options.sys.shell = {
    enable = lib.mkEnableOption "Enable shell management" // {
      default = true;
    };

    defaults = {
      pager = lib.mkOption {
        type = lib.types.str;
        default = lib.getExe pkgs.moar;

        description = ''
          CLI pager to use for the user. This gets set to the PAGER env
          variable.
        '';
      };

      editor = lib.mkOption {
        type = lib.types.str;
        default = lib.getExe pkgs.helix;

        description = ''
          CLI editor to use for the user. This gets set to the EDITOR env
          variable.
        '';
      };

      viewer = lib.mkOption {
        type = lib.types.str;
        default = "${lib.getExe pkgs.helix} -R";

        description = ''
          CLI file viewer to use for the user. This gets set to the VISUAL env
          variable.
        '';
      };
    };

    aliases = lib.mkOption {
      type = with lib.types; attrsOf str;

      default = {
        h = "history";
        pg = "pgrep";
        cp = "cp -r";

        # Make things human-readable
        dd = "dd status=progress";
        df = "df -Th";
        du = "du -h";
        free = "free -h";
        pkill = "pkill -e";

        # VI Keys pls
        info = "info --vi-keys";

        # Dissuade bad behavior
        rm = "rm --interactive";
      };

      description = ''
        Aliases to add for the shell.
      '';
    };

    historyIgnore = lib.mkOption {
      type = with lib.types; listOf str;

      default = [
        "cd *"
        "exit"
        "export *"
        "kill *"
        "pkill"
        "pushd *"
        "popd"
        "rm *"
        "tp *"
        "z *"
      ];

      description = ''
        Shell patterns to exclude from the history. Supported in Bash and Zsh.
      '';
    };

    bash.enable = lib.mkEnableOption "Enable default bash config" // {
      default = true;
    };
    bat.enable = lib.mkEnableOption "Enable default bat config" // {
      default = true;
    };

    eza = {
      enable = lib.mkEnableOption "Default eza config" // {
        default = true;
      };
      package = lib.mkPackageOption pkgs "eza" { };
    };

    less.enable = lib.mkEnableOption "Enable default less config" // {
      default = true;
    };
    tmux.enable = lib.mkEnableOption "Enable default tmux config" // {
      default = true;
    };
    starship.enable = lib.mkEnableOption "Enable default starship config" // {
      default = true;
    };
    zsh.enable = lib.mkEnableOption "Enable default zsh config";

    fish = {
      enable = lib.mkEnableOption "fish config";

      package = lib.mkPackageOption pkgs "fish" { };

      theme = lib.mkOption {
        type = lib.types.str;
        default = "Nord";

        description = ''
          The theme to set for the command line.
        '';
      };
    };

    trashy = {
      enable = lib.mkEnableOption "trashy, a rm alternative" // {
        default = true;
      };

      package = lib.mkPackageOption pkgs "trashy" { };

      enableAliases = lib.mkEnableOption "trashy aliases" // {
        default = true;
      };
    };

    zoxide.enable = lib.mkEnableOption "Enable zoxide" // {
      default = true;
    };

    z-lua.enable = lib.mkEnableOption "Enable z-lua";
    autojump.enable = lib.mkEnableOption "Enable autojump";

    fcp.enable = lib.mkEnableOption "Enable replacing cp with fcp";

    extraShells = lib.mkOption {
      type = with lib.types; listOf package;

      default = with pkgs; [
        elvish
        powershell
      ];
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home = {
          packages = cfg.extraShells;

          shellAliases = cfg.aliases // {
            # Editor aliases
            "v" = cfg.defaults.editor;
          };

          sessionVariables = {
            "PAGER" = cfg.defaults.pager;
            "EDITOR" = cfg.defaults.editor;
            "VISUAL" = cfg.defaults.viewer;
          };
        };

        programs = {
          autojump.enable = cfg.autojump.enable;
          z-lua.enable = cfg.z-lua.enable;
        };
      }

      (lib.mkIf cfg.trashy.enable {
        home = {
          packages = [ cfg.trashy.package ];

          shellAliases = lib.mkIf cfg.trashy.enableAliases { "tp" = "trash put"; };
        };
      })

      (lib.mkIf cfg.bash.enable {
        programs.bash = {
          inherit (cfg) historyIgnore;
          inherit (cfg.bash) enable;

          historyFile = "${config.xdg.dataHome or "$XDG_DATA_HOME"}/bash/bash_history";
          historyControl = [
            "ignoredups"
            "ignorespace"
          ];

          initExtra = lib.mkIf config.sys.git.enable posixGitFunctions;
        };
      })

      (lib.mkIf cfg.bat.enable {
        home.shellAliases."cat" = "bat";

        programs.bat = {
          inherit (cfg.bat) enable;

          config = {
            theme = "base16";
            italic-text = "always";
            style = "full";
          };
        };
      })

      (lib.mkIf cfg.eza.enable {
        home.shellAliases = {
          "ls" = "${lib.getExe cfg.eza.package} --classify --color=always --icons";
          "la" = "ls --long --all --binary --group --header --git-repos --color-scale";
          "tree" = "la --tree";
          # Re-alias
          "l" = "ls";
          "ll" = "la";
        };

        programs.eza = {
          inherit (cfg.eza) enable package;
        };
      })

      (lib.mkIf cfg.less.enable {
        home.shellAliases."more" = "less";

        # TODO: Figure out a lesskey config
        programs.less.enable = true;
      })

      (lib.mkIf cfg.starship.enable {
        programs.starship = {
          inherit (cfg.starship) enable;

          package = pkgs.starship;

          # Broken sometimes
          enableNushellIntegration = false;

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
              # elvish_indicator = "elvish";
              # tcsh_indicator = "tcsh";
              # xonsh_indicator = "xonsh";
              unknown_indicator = "?";
            };
          };
        };
      })

      (lib.mkIf cfg.tmux.enable {
        programs.tmux = {
          inherit (cfg.tmux) enable;

          clock24 = true;
          keyMode = "vi";
          prefix = "C-a";
          shell = lib.getExe pkgs.zsh;

          plugins = with pkgs.tmuxPlugins; [
            cpu
            prefix-highlight
            resurrect
          ];

          extraConfig = ''
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

      (lib.mkIf cfg.fish.enable {
        programs.fish = {
          inherit (cfg.fish) enable;

          functions = {
            gcmsgp = ''
              git commit --verbose --message $argv && git push --verbose
            '';

            gcmsgpf = ''
              git commit --verbose --message $argv && git push --verbose --force-with-lease --force-if-includes
            '';
          };

          loginShellInit = ''
            set -U fish_features all
            set -U fish_greeting
          '';

          interactiveShellInit = ''
            fish_config theme choose '${cfg.fish.theme}'
            fish_vi_key_bindings
          '';

          plugins = [
            {
              name = "sponge";
              src = pkgs.fishPlugins.sponge;
            }
            {
              name = "pisces";
              src = pkgs.fishPlugins.pisces;
            }
            {
              name = "colored-man-pages";
              src = pkgs.fishPlugins.colored-man-pages;
            }

            # TODO: Try these out
            # {
            #   name = "grc";
            #   src = pkgs.fishPlugins.grc;
            # }
            # {
            #   name = "humantime-fish";
            #   src = pkgs.fishPlugins.humantime-fish;
            # }
          ];
        };
      })

      (lib.mkIf cfg.zsh.enable {
        programs.zsh = {
          inherit (cfg.zsh) enable;

          dotDir = ".config/zsh";
          shellGlobalAliases."UUID" = "$(uuidgen | tr -d \\n)";
          defaultKeymap = "viins";
          initExtra = lib.mkIf config.sys.git.enable posixGitFunctions;
          enableAutosuggestions = true;

          oh-my-zsh = {
            enable = true;

            plugins = [
              "adb"
              "alias-finder"
              "aliases"
              "ansible"
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
              "tmux"
              "urltools"
              "web-search"
              # (lib.optionalString cfg.zoxide "zoxide") # NOTE: Sourcing provided by home-manager module
            ];
          };

          plugins = [
            {
              name = "fast-syntax-highlighting";
              src = pkgs.zsh-fast-syntax-highlighting;
              file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
            }
            {
              name = "history-search-multi-word";
              src = pkgs.zsh-history-search-multi-word;
              file = "share/zsh/zsh-history-search-multi-word/history-search-multi-word.plugin.zsh";
            }
            {
              name = "you-should-use";
              src = pkgs.zsh-you-should-use;
              file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
            }
          ];

          history = {
            path = "${config.xdg.dataHome or "$XDG_DATA_HOME"}/zsh/zsh_history";
            size = 100000;
            save = 1000000;

            ignorePatterns = cfg.historyIgnore;

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

      (lib.mkIf cfg.zoxide.enable {
        home.shellAliases = {
          "za" = "zoxide add";
          "zq" = "zoxide query";
          "zr" = "zoxide remove";

          "cd" = "z";
          "pushd" = "z";
          "popd" = "z -";
        };

        programs.zoxide.enable = true;
      })

      (lib.mkIf cfg.fcp.enable {
        home.packages = [ pkgs.fcp ];
        home.shellAliases."cp" = lib.mkForce "fcp";
      })
    ]
  );
}
