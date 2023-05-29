_: {
  config = {
    sys.dev.enable = true;

    test.stubs.gh = { };

    nmt.script = ''
      configDir="home-files/.config"
      assertDirectoryNotEmpty "$configDir/gh"

      ghConfig="$configDir/gh/config.yml"
      assertFileExists "$ghConfig"
      assertFileContains "$ghConfig" 'git_protocol: ssh'

      assertFileExists "home-files/.editorconfig"
      assertFileContains "home-files/.editorconfig" 'root = true'
    '';
  };
}

