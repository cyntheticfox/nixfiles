_: {
  config = {
    sys.gnupg.enable = true;

    test.stubs.gnupg = { };

    nmt.script = ''
      gpgDir="home-files/.gnupg"
      assertDirectoryNotEmpty "$gpgDir"
      assertFileExists "$gpgDir/gpg.conf"
      assertFileExists "$gpgDir/gpg-agent.conf"
    '';
  };
}
