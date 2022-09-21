{ config, ... }: {
  home.shellAliases = {
    "l" = "exa --classify --color=always --icons";
    "ls" = "exa --classify --color=always --icons";
    "la" = "exa --classify --color=always --icons --long --all --binary --group --header --git --color-scale";
    "ll" = "exa --classify --color=always --icons --long --all --binary --group --header --git --color-scale";
    "tree" = "exa --classify --color=always --icons --long --all --binary --group --header --git --color-scale --tree";
  };

  programs.exa.enable = true;
}
