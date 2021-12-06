{ lib
, pkgs
, buildPythonPackage
, fetchFromGitHub
, blessed
, docopt
, funcy
, pick
, pixcat
, pixivpy
, placeholder
, plyer
, pytest
, returns
, withUeberzug ? false
, ueberzug
}:

buildPythonPackage rec {
  pname = "koneko";
  version = "0.12.2";

  src = fetchFromGitHub {
    owner = "akazukin5151";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-hZ/eH33AIiwUfNiiuDtQxz2w2w2nyM7rKpNtn0sRA8U=";
  };

  propagatedBuildInputs = [
    pkgs.curl
    pkgs.desktop-file-utils
    pkgs.xdg-utils

    blessed
    docopt
    funcy
    pick
    pixcat
    pixivpy
    placeholder
    plyer
    returns
  ] ++ lib.optional withUeberzug [ ueberzug ];

  patches = [
    ./paths.patch
  ];

  preBuild = ''
    mkdir -p $out/share/koneko
    cp -r $src/pics/ $out/share/koneko/
    cp $src/example_config.ini $out/share/koneko/
    cp $src/pixiv-url.desktop $out/share/koneko/
  '';

  checkInputs = [ pytest ];

  checkPhase = ''
    pytest testing/ -vvvv -l
  '';

  meta = with lib; {
    homepage = "https://github.com/akazukin5151/koneko";
    description = "Browse pixiv in the terminal using kitty's icat to display images";
    license = licenses.gpl3;
  };
}
