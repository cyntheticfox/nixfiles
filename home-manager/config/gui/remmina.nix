{ config, pkgs, ... }: {
  home.packages = with pkgs; [ remmina ];

  xdg.mimeApps.defaultApplications."application/x-rdp" = "org.remmina.Remmina.desktop";

  xdg.dataFile."mime/packages/application-x-rdp.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
      <mime-type type="application/x-rdp">
        <comment>rdp file</comment>
        <icon name="application-x-rdp"/>
        <glob-deleteall/>
        <glob pattern="*.rdp"/>
      </mime-type>
    </mime-info>
  '';
}
