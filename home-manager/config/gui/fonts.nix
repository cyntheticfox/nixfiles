{ config, pkgs, lib, ... }: {
  home.packages = with pkgs; [
    dejavu_fonts
    fira
    fira-code-symbols
    fira-mono
    nerdfonts
  ];

  xdg.configFile."fontconfig/fonts.conf".text = lib.mkDefault ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
        <match target="pattern">
            <test qual="any" name="family"><string>emoji</string></test>
            <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
        </match>

        <match target="pattern">
            <test qual="any" name="family"><string>emoji</string></test>
            <edit name="family" mode="assign" binding="same"><string>Fira Code Nerd Font</string></edit>
        </match>

        <alias>
            <family>monospace</family>
            <prefer>
                <family>Fira Code Nerd Font Mono</family>
                <family>Noto Color Emoji</family>
            </prefer>
        </alias>

        <selectfont>
            <rejectfont>
                <pattern>
                    <patelt name="family">
                        <string>DejaVu Sans Mono</string>
                    </patelt>
                </pattern>
            </rejectfont>
        </selectfont>
    </fontconfig>
  '';
}
