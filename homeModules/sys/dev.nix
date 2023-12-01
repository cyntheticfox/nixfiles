{ config, lib, pkgs, ... }:

let
  cfg = config.sys.dev;
in
{
  options.sys.dev = {
    enable = lib.mkEnableOption "dev configuration packages";

    java = {
      enable = lib.mkEnableOption "Java user-wide";

      package = lib.mkPackageOption pkgs "openjdk" { };

      debugPackage = lib.mkPackageOption pkgs "jdb" { };
    };

    packages = lib.mkOption {
      type = with lib.types; listOf package;

      default = with pkgs; [
        act
        cargo
        cloc
        deno
        gcc_latest
        grex
        htmlq
        hyperfine
        jq

        (llvmPackages_latest.clang.overrideAttrs (_: {
          meta.priority = gcc_latest.meta.priority + 1;
        }))

        llvmPackages_latest.clang-manpages
        nodejs_latest
        pastel
        python3

        # Manuals
        man-pages-posix
        stdmanpages

        # General binary tools
        bintools
        bingrep
        bloaty

        # C/General
        gdb
        lldb
        valgrind
        rr

        # RE/General
        # cutter # TODO: Uncomment when fixed
        exiftool
        hexyl
        radare2
        rehex
        xxd
      ];

      description = ''
        Options for managing installed dev packages.
      '';
    };

    manageDirenvConfig = lib.mkEnableOption "Enable direnv management" // { default = true; };

    manageGhConfig = lib.mkEnableOption "Enable gh management" // { default = true; };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.shellAliases = {
        "gcc" = "gcc -fdiagnostics-color";
        "clang" = "clang -fcolor-diagnostics";
      };

      home.packages = cfg.packages;

      # Load editorconfig file as well
      home.file.".editorconfig".text = ''
        # .editorconfig
        #
        # Source for controlling tabulation and formatting of files by name
        #
        # https://editorconfig.org
        #
        # Plugins required for...
        #
        # Vim: https://github.com/editorconfig/editorconfig-vim
        # Neovim: https://github.com/gpanders/editorconfig.nvim
        # VSCode/VSCodium: https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig

        root = true

        # Set file defaults
        [*]
        charset = utf-8
        end_of_line = lf
        indent_size = 2
        indent_style = space
        insert_final_newline = true
        trim_trailing_whitespace = true

        [*.{rs,py}]
        indent_size = 4

        [*.md]
        trim_trailing_whitespace = false

        [Makefile]
        indent_size = 8
        indent_style = tab
      '';
    }

    (lib.mkIf cfg.java.enable {
      home.packages = [ cfg.java.debugPackage ];

      programs.java = {
        inherit (cfg.java) enable package;
      };
    })

    (lib.mkIf cfg.manageDirenvConfig {
      programs.direnv = {
        enable = true;

        nix-direnv.enable = true;
      };
    })

    (lib.mkIf cfg.manageGhConfig {
      programs.gh = {
        enable = true;

        settings = {
          git_protocol = "ssh";
          prompt = "enabled";
          pager = config.home.sessionVariables.PAGER or "less";
          editor = config.home.sessionVariables.EDITOR or "nano";

          aliases = {
            co = "pr checkout";
            pv = "pr view";
          };
        };
      };
    })
  ]);
}
