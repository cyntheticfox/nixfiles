{ pkgs, ... }: {
  home.packages = with pkgs; [
    libreoffice
    mupdf
  ];

  xdg.mimeApps.defaultApplications =
    let
      mupdf = "mupdf.desktop";
    in
    {
      "application/pdf" = mupdf;
      "application/x-pdf" = mupdf;
      "application/x-cbz" = mupdf;
      "application/oxps" = mupdf;
      "application/vnd.ms-xpsdocument" = mupdf;
      "application/epub+zip" = mupdf;
    };
}
