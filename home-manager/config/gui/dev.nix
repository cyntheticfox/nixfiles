{ config, pkgs, ... }: {
  home.sessionVariables = {
    EDITOR_GRAPHICAL = "${pkgs.neovim-qt}/bin/nvim-qt";
    VISUAL_GRAPHICAL = config.home.sessionVariables.EDITOR_GRAPHICAL;
  };

  home.packages = with pkgs; [
    neovim-qt
    postman
    wl-color-picker
    vscode
  ];
}
