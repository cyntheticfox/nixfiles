_: {
  config = {
    sys.fonts.enable = true;

    test.stubs.fontconfig = { };

    nmt.script = ''
      assertDirectoryNotEmpty home-path/lib/fontconfig/cache
    '';
  };
}
