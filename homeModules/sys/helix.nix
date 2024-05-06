{ config, lib, pkgs, ... }:

let
  cfg = config.sys.helix;

  mapListToAttrs = lib.flip lib.genAttrs;
  mkLspOptions = mapListToAttrs (lsp-name: {
    enable = lib.mkEnableOption lsp-name;
    package = lib.mkPackageOption pkgs lsp-name { };
  });

  mkPackagesConf = builtins.map (
    lsp-name: lib.mkIf cfg.lsp.${lsp-name}.enable {
      programs.helix.extraPackages = [ cfg.lsp.${lsp-name}.package ];
    }
  );

  lsps = [
    "marksman"
    "nil"
    "rust-analyzer"
  ];
in
{
  options.sys.helix = {
    enable = lib.mkEnableOption "Helix text editor";
    package = lib.mkPackageOption pkgs "helix" { };
    lsp = mkLspOptions lsps;
    defaultEditor = lib.mkEnableOption "helix as the default editor";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge (
      [{
        programs.helix = {
          inherit (cfg) enable package defaultEditor;

          settings = {
            theme = "onedark";

            editor = {
              line-number = "relative";
              scrolloff = 7;
              shell = [ "fish" "-c" ];
              cursorline = true;
              auto-info = false;
              true-color = true;
              rulers = [ 80 ];
              bufferline = "always";
              color-modes = true;
              # popup-border = "all"; # TODO: Undo once 24.03

              statusline = {
                left = [
                  "mode"
                  "version-control"
                  "spinner"
                  "diagnostics"
                  "file-name"
                  "read-only-indicator"
                  "file-modification-indicator"
                ];

                right = [
                  "register"
                  "file-encoding"
                  "file-type"
                  "file-line-ending"
                  "position-percentage"
                  "position"
                ];

                separator = "/";
              };

              lsp = {
                display-messages = true;
                auto-signature-help = false;
              };

              cursor-shape = {
                normal = "block";
                insert = "bar";
                select = "underline";
              };

              whitespace.render = {
                space = "none";
                tab = "all";
                nbsp = "all";
                nnbsp = "all";
                newline = "none";
              };

              indent-guides = {
                render = true;
                character = "┆";
              };

              gutters.line-numbers.min-width = 1;
            };

            keys = {
              normal = {
                "A-," = "goto_previous_buffer";
                "A-." = "goto_next_buffer";
                "A-x" = "extend_to_line_bounds";
                "X" = [
                  "extend_line_up"
                  "extend_to_line_bounds"
                ];
              };

              select = {
                "A-x" = "extend_to_line_bounds";
                "X" = [
                  "extend_line_up"
                  "extend_to_line_bounds"
                ];
              };
            };
          };
        };
      }]
      ++ mkPackagesConf lsps
    )
  );
}
