{ lib
, fetchurl
, appimageTools
, pkgs
, gtk3
, gsettings-desktop-schemas
}:

let
  pname = "hyperchroma";
  version = "0.9.0-beta";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://cdn.hyperchroma.app/${pname}-${version}-linux-x86_64.AppImage";
    name = "${pname}-${version}.AppImage";
    sha512 = "f473e370a86088f2c19a8054638c320cf55e296437bd62bbd3754eb2379bc8c947d752a711ba0855dc658c1d79f3364b3f5ab4952300f334d6bccd5b3e381daa";
  };

  profile = ''
    export XDG_DATA_DIRS=${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS
  '';

  appimageContents = appimageTools.extractType2 {
    inherit name src;
  };

  runDeps = with pkgs; [
    glib
  ];

in
appimageTools.wrapType2 {
  inherit name src profile;

  multiPkgs = null;
  extraPkgs = pkgs: (appimageTools.defaultFhsEnvArgs.multiPkgs pkgs)
    ++ runDeps;

  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${pname}
    install -m 444 -D ${appimageContents}/hyperchroma.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/hyperchroma.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/0x0/apps/hyperchroma.png \
      $out/share/icons/hicolor/512x512/apps/hyperchroma.png
  '';

  meta = with lib; {
    description = "A music player that animates music and images into real-time music videos.";
    homepage = "https://hyperchroma.app";
    changelog = "https://github.com/Hyperchroma/hyperchroma/blob/master/CHANGELOG.md";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
