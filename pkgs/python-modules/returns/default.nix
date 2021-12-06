{ lib
, buildPythonPackage
, fetchFromGitHub
, poetry-core
, typing-extensions
}:

buildPythonPackage rec {
  pname = "returns";
  version = "0.16.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "dry-python";
    repo = pname;
    rev = version;
    sha256 = "sha256-w6Xe3uG+HmcIS5Ngaw49ZT9nxzPEFrl0dTGDgPrST58=";
  };

  buildInputs = [ poetry-core ];

  propagatedBuildInputs = [ typing-extensions ];

  meta = with lib; {
    description = "Make your functions return something meaningful, typed, and safe!";
    homepage = "https://github.com/dry-python/returns";
    license = licenses.bsd2;
  };
}
