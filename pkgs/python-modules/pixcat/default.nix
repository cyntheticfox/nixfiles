{ lib
, buildPythonPackage
, fetchPypi
, blessed
, docopt
, pillow
, requests
}:

buildPythonPackage rec {
  pname = "pixcat";
  version = "0.1.4";

  src = fetchPypi {
    inherit pname version;

    sha256 = "sha256-ZXyP4EUTyuzM1ghrNHqkuF22tMD3YbFiy5zXiavnq7Y=";
  };

  buildInputs = [
    blessed
    docopt
  ];

  propagatedBuildInputs = [
    pillow
    requests
  ];

  meta = with lib; {
    description = "Display images on a kitty terminal with optional custom/thumbnail/fit-to-screen resizing";
    homepage = "https://github.com/mirukana/pixcat";
    license = licenses.lgpl3Only;
  };
}
