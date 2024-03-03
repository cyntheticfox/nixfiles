_: {
  config = {
    sys.shell = {
      enable = true;

      zsh.enable = true;
    };

    test.stubs.zsh = { };

    nmt.script = ''
      assertDirectoryNotEmpty home-files/.config/zsh
      assertFileExists home-files/.config/zsh/.zshrc
      assertFileExists home-files/.config/starship.toml

      assertFileExists home-files/.config/bat/config
      assertFileExists home-files/.config/tmux/tmux.conf
    '';
  };
}
