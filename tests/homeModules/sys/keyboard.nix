{ lib, ... }:

with lib;

{
  config = {
    sys.keyboard.enable = true;

    nmt.script = ''
      fcitxDir="home-files/.config/fcitx5"

      assertDirectoryExists $fcitxDir
      assertDirectoryNotEmpty $fcitxDir

      assertFileExists $fcitxDir/profile
      assertFileContains $fcitxDir/profile 'DefaultIM=mozc'
      assertFileContains $fcitxDir/profile 'Name=mozc'

      assertFileExists $fcitxDir/config
      assertFileContains $fcitxDir/config 'EnumerateSkipFirst=False'
      assertFileContains $fcitxDir/config '1=Hangul'
      assertFileContains $fcitxDir/config '0=Control+Shift+Super+space'
      assertFileContains $fcitxDir/config '0=Control+Alt+P'

      assertDirectoryExists $fcitxDir/conf
      assertDirectoryNotEmpty $fcitxDir/conf

      assertFileExists $fcitxDir/conf/clipboard.conf
      assertFileContains $fcitxDir/conf/clipboard.conf 'Number of entries=5'

      assertFileExists $fcitxDir/conf/notifications.conf
      assertFileContains $fcitxDir/conf/notifications.conf 'HiddenNotifications='

      assertFileExists $fcitxDir/conf/quickphrase.conf
      assertFileContains $fcitxDir/conf/quickphrase.conf 'FallbackSpellLanguage=en'
    '';
  };
}
