{ lib, ... }:

with lib;

{
  config = {
    sys.music.enable = true;

    test.stubs.mpd = { };
    test.stubs.mpdris2 = { };

    nmt.script = ''
      configDir="home-files/.config"
      assertDirectoryNotEmpty "$configDir/vimpc"

      vimpcConfig="$configDir/vimpc/vimpcrc"

      assertFileExists "$vimpcConfig"
      assertFileContains "$vimpcConfig" 'set windows library,lists,playlist'
      assertFileContains "$vimpcConfig" 'set albumartist'
      assertFileContains "$vimpcConfig" 'set autoscroll'
      assertFileContains "$vimpcConfig" 'map J :tabprevious<C-M>'
      assertFileContains "$vimpcConfig" 'map K :tabnext<C-M>'

      mpdConfig=$(grep -o '/nix/store/.*-mpd.conf' $TESTED/home-files/.config/systemd/user/mpd.service)
      # assertFileContains "$mpdConfig" 'audio_output {\n  type "pipewire"\n  name "PipeWire Sound Server"\n}'
    '';
  };
}
