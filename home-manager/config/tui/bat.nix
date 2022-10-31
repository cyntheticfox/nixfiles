_: {
  home.shellAliases."cat" = "bat";

  programs.bat = {
    enable = true;

    config = {
      theme = "base16";
      italic-text = "always";
      style = "full";
    };
  };
}
