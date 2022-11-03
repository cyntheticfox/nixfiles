{ lib, ... }:

with lib;

{
  config = {
    sys.shell.enable = true;

    test.stubs.zsh = { };

    nmt.script = ''
      assertDirectoryNotEmpty home-files/.config/zsh
      assertFileExists home-files/.config/zsh/.zshrc
      assertFileExists home-files/.config/starship.toml
    '';
  };
}
