{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.sys.shell;
in
{
  options.sys.shell = {
    enable = mkEnableOption "Enable shell management" // {
      default = true;
    };

    pager = mkOption {
      type = types.nullOr types.string;
      default = "${pkgs.less}/bin/less";
      description = ''
        CLI pager to use for the user. This gets set to the PAGER env
        variable.
      '';
    };

    editor = mkOption {
      type = types.nullOr types.string;
      default = "${pkgs.neovim}/bin/nvim";
      description = ''
        CLI editor to use for the user. This gets set to the EDITOR env
        variable.
      '';
    };

    viewer = mkOption {
      type = types.nullOr types.string;
      default = "${pkgs.neovim}/bin/nvim -R";
      description = ''
        CLI file viewer to use for the user. This gets set to the VISUAL env
        variable.
      '';
    };

    aliases = mkOption {
      type = types.attrsOf types.string;
      default = {
        "h" = "history";
        "pg" = "pgrep";

        # Editor aliases
        "v" = config.home.sessionVariables.EDITOR;

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

    manageZshConfig = mkEnableOption "Enable default zsh config" // { default = true; };

    manageStarshipConfig = mkEnableOption "Enable default starship config" // { default = true; };

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


  config = mkIf cfg.enable {
    home.packages = cfg.extraShells;

    home.shellAliases = cfg.aliases;
    home.sessionVariables = {
      "PAGER" = cfg.pager;
      "EDITOR" = cfg.editor;
      "VISUAL" = cfg.viewer;
    };

    programs.autojump.enable = cfg.autojump;
    programs.z-lua.enable = cfg.z-lua;
    programs.zoxide.enable = cfg.zoxide;

    programs.starship = mkIf cfg.manageStarshipConfig {
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

    programs.zsh = mkIf cfg.manageZshConfig {
      enable = mkDefault true;
      dotDir = mkDefault ".config/zsh";

      shellGlobalAliases = mkDefault {
        "UUID" = "$(uuidgen | tr -d \\n)";
      };

      defaultKeymap = mkDefault "viins";

      initExtra = mkDefault ''
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

      enableAutosuggestions = mkDefault true;
      oh-my-zsh = {
        enable = mkDefault true;

        plugins = mkDefault [
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

      plugins = mkDefault [
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

      history = mkDefault {
        size = 102400;
        save = 10240;
        ignorePatterns = [
          "rm *"
          "pkill *"
          "cd *"
        ];
        expireDuplicatesFirst = true;
      };

      sessionVariables = mkDefault {
        "ZSH_AUTOSUGGEST_USE_ASYNC" = "1";
      };

      initExtraFirst = mkDefault ''
        setopt AUTO_CD
        setopt PUSHD_IGNORE_DUPS
        setopt PUSHD_SILENT

        setopt ALWAYS_TO_END
        setopt AUTO_MENU
        setopt COMPLETE_IN_WORD
        setopt FLOW_CONTROL
      '';
    };
  };
}
