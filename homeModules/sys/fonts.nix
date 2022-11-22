{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.sys.fonts;
in
{
  options.sys.fonts = {
    enable = mkEnableOption "Manage fonts at a user level";

    packages = mkOption {
      type = with types; listOf package;
      default = with pkgs; [
        dejavu_fonts
        fira
        fira-mono
        font-awesome
        noto-fonts-emoji
        rictydiminished-with-firacode
      ];
      description = "Font packages to install for the user";
    };

    nerdfontsPackage = mkOption {
      type = types.nullOr types.package;
      default = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
      defaultText = literalExpression "pkgs.nerdfonts.override { fonts = [ \"FiraCode\" ]; }";
      description = "Nerdfonts package to install. Set to `null` to disable.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = cfg.packages ++ [ cfg.nerdfontsPackage ];

    fonts.fontconfig.enable = true;
  };
}
