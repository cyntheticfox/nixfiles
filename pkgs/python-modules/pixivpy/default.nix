{ lib
, buildPythonPackage
, fetchFromGitHub
, cloudscraper
}:

buildPythonPackage rec {
  pname = "PixivPy";
  version = "3.5.10";

  src = fetchFromGitHub {
    owner = "upbit";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-bQC3e2IqNkrXawhhacIv1qpwzqY8zZBNIp3Hif1ICiY=";
  };

  propagatedBuildInputs = [ cloudscraper ];

  meta = with lib; {
    description = "Pixiv API for Python (with Auth supported)";
    homepage = "https://github.com/upbit/pixivpy";
    license = licenses.unlicense;
  };
}
