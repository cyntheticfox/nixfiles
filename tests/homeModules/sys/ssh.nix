_: {
  config = {
    sys.ssh = {
      enable = true;

      extraMatchBlocks = {
        "bitbucket bitbucket.com" = {
          hostname = "bitbucket.com";
          user = "git";
          port = 22;
          identityFile = "~/.ssh/bitbucket_id_ed25519";
        };
      };
    };

    test.stubs.ssh = { };

    nmt.script = ''
      assertDirectoryNotEmpty "home-files/.ssh"
      assertFileExists "home-files/.ssh/config"
      assertFileContains "home-files/.ssh/config" 'Host github github.com'
      assertFileContains "home-files/.ssh/config" 'Host bitbucket bitbucket.com'
    '';
  };
}
