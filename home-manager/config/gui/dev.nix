{ config, pkgs, ... }: {
  imports = [ ./../tui/neovim.nix ];

  home.sessionVariables = {
    EDITOR_GRAPHICAL = "nvim-qt";
    VISUAL_GRAPHICAL = "nvim-qt";
  };

  home.packages = with pkgs; [
    neovim-qt
    postman
    vscode
  ];
}
