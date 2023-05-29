_: {
  config = {
    sys.music.enable = true;

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
    '';
  };
}
