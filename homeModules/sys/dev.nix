{ config, lib, pkgs, ... }:

let
  cfg = config.sys.dev;

  # lib.types.attrsWithMatch = pattern: lib.mkOptionType {
  #   name = "attrsWithMatch";
  #   description = "attribute set with names of a certain pattern";
  #   check = x: builtins.isAttrs x && builtins.all (i: (builtins.match pattern i) != null) (builtins.attrNames x);
  #   merge = foldl' (res: def: res // def.value) { };
  #   emptyValue = { value = { }; };
  # };

  # lib.types.attrsOfWithMatch = pattern: elemType: lib.mkOptionType {
  #   name = "attrsOfWithMatch";
  #   description = "attribute set of ${optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType} with names of a certain pattern";
  #   check = x: builtins.isAttrs x && builtins.all (i: (builtins.match pattern i) != null) (builtins.attrNames x);
  #
  #   merge = loc: defs:
  #     builtins.mapAttrs (_: v: v.value) (lib.filterAttrs (_: v: v ? value) (builtins.zipAttrsWith
  #       (name: defs:
  #         (mergeDefinitions (loc ++ [ name ]) elemType defs).optionalValue
  #       )
  #       (builtins.map (def: builtins.mapAttrs (_: value: { inherit (def) file; inherit value; }) def.value) defs)));
  #
  #   emptyValue = { value = { }; };
  # };
  #
  # # See https://spec.editorconfig.org/
  # styleModule = lib.types.submodule ({ config, ... }: {
  #   options = {
  #     indent_style = lib.mkOption {
  #       type = with lib.types; nullOr (enum [ "tab" "space" "unset" ]);
  #       default = null;
  #     };
  #
  #     indent_size = lib.mkOption {
  #       type = with lib.types; nullOr (either ints.unsigned "unset");
  #       default = null;
  #     };
  #
  #     tab_width = lib.mkOption {
  #       type = with lib.types; nullOr (either ints.unsigned "unset");
  #       default = null;
  #     };
  #
  #     end_of_line = lib.mkOption {
  #       type = with lib.types; nullOr (enum [ "lf" "cr" "crlf" "unset" ]);
  #       default = null;
  #     };
  #
  #     charset = lib.mkOption {
  #       type = with lib.types; nullOr (enum [ "latin1" "utf-8" "utf-8-bom" "utf-16be" "utf-16le" "unset" ]);
  #       default = null;
  #     };
  #
  #     trim_trailing_whitespace = lib.mkOption {
  #       type = with lib.types; nullOr (either bool "unset");
  #       default = null;
  #     };
  #
  #     insert_final_newline = lib.mkOption {
  #       type = with lib.types; nullOr (either bool "unset");
  #       default = null;
  #     };
  #   };
  # });
in
{
  options.sys.dev = {
    enable = lib.mkEnableOption "Enable dev configuration packages";

    # TODO: Make this a thing
    # defaultStyle = lib.mkOption {
    #   type = styleModule;
    #
    #   default = {
    #     indent_style = "space";
    #     indent_size = 2;
    #     tab_width = 8;
    #     end_of_line = "lf";
    #     charset = "utf-8";
    #     trim_trailing_whitespace = true;
    #     insert_final_newline = true;
    #   };
    # };
    #
    # styles = lib.mkOption {
    #   type = lib.types.attrsOfWithMatch "^/?$" styleModule;
    #   default = { };
    # };

    packages = lib.mkOption {
      type = with lib.types; listOf package;

      default = with pkgs; [
        act
        cargo
        cloc
        deno
        gcc_latest
        grex
        hexyl
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

        # Repository Management
        pre-commit
        git-secrets

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
        cutter
        radare2
        rehex
      ];

      description = "Options for managing installed file packages";
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

      programs.java = {
        enable = true;

        package = pkgs.openjdk;
      };

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

        [*.md]
        trim_trailing_whitespace = false

        [Makefile]
        indent_size = 8
        indent_style = tab
      '';
    }

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
