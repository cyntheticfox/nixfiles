{ lib, ... }:

with lib;

{
  config = {
    sys.fonts.enable = true;

    nmt.script = ''
      assertDirectoryNotEmpty home-path/lib/fontconfig/cache
    '';
  };
}
