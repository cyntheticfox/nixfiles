{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    prefix = "C-a";
    shell = "${pkgs.zsh}/bin/zsh";
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
}
