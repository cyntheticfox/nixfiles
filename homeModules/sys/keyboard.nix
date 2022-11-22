{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.sys.keyboard;
in
{
  options.sys.keyboard = {
    enable = mkEnableOption "Manage keyboard for the user (extra languages)";
  };

  config = mkIf cfg.enable {
    i18n.inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [ fcitx5-mozc ];
    };

    # Fcitx5 will _add comments_ if they're not there for some reason
    xdg.configFile."fcitx5/profile".text = ''
      [Groups/0]
      # Group Name
      Name=Default
      # Layout
      Default Layout=us
      # Default Input Method
      DefaultIM=mozc

      [Groups/0/Items/0]
      # Name
      Name=keyboard-us
      # Layout
      Layout=

      [Groups/0/Items/1]
      # Name
      Name=mozc
      # Layout
      Layout=

      [GroupOrder]
      0=Default

    '';

    xdg.configFile."fcitx5/config".text = ''
      [Hotkey]
      EnumerateWithTriggerKeys=True
      AltTriggerKeys=
      EnumerateSkipFirst=False
      EnumerateGroupForwardKeys=
      EnumerateGroupBackwardKeys=

      [Hotkey/TriggerKeys]
      0=Zenkaku_Hankaku
      1=Hangul

      [Hotkey/EnumerateForwardKeys]
      0=Control+Shift+Super+space

      [Hotkey/ActivateKeys]
      0=Hangul_Hanja

      [Hotkey/DeactivateKeys]
      0=Hangul_Romaja

      [Hotkey/PrevPage]
      0=Up

      [Hotkey/NextPage]
      0=Down

      [Hotkey/PrevCandidate]
      0=Shift+Tab

      [Hotkey/NextCandidate]
      0=Tab

      [Hotkey/TogglePreedit]
      0=Control+Alt+P

      [Behavior]
      ActiveByDefault=False
      ShareInputState=No
      PreeditEnabledByDefault=Ture
      ShowInputMethodInformation=True
      ShowInputMethodInformationWhenFocusIn=False
      CompactInputMethodInformation=True
      ShowFirstInputMethodInformation=True
      DefaultPageSize=5
      EnabledAddons=
      DisabledAddons=
      PreloadInputMethod=True
    '';

    xdg.configFile."fcitx5/conf/clipboard.conf".text = ''
      TriggerKey=
      PastePrimaryKey=
      Number of entries=5
    '';

    xdg.configFile."fcitx5/conf/notifications.conf".text = ''
      # Hidden Notifications
      HiddenNotifications=

    '';

    xdg.configFile."fcitx5/conf/quickphrase.conf".text = ''
      TriggerKey=
      Choose Modifier=None
      Spell=True
      FallbackSpellLanguage=en
    '';
  };
}
