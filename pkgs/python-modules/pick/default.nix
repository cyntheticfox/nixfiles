{ lib
, buildPythonPackage
, fetchFromGitHub
, poetry-core
}:

buildPythonPackage rec {
  pname = "pick";
  version = "1.0.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "wong2";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-B1v5UTpPrjVaW/AGlwv6UzUPmdg6afWZhpTXnwh913I=";
  };

  buildInputs = [ poetry-core ];

  meta = with lib; {
    description = "A samll python library to help you create curses-based interactive selection lists in the terminal";
    homepage = "https://github.com/wong2/pick";
    license = licenses.mit;
  };
}
