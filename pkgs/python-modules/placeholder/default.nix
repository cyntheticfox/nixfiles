{ lib
, buildPythonPackage
, fetchFromGitHub
, pytest
, pytest-parametrized
}:

buildPythonPackage rec {
  pname = "placeholder";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "coady";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-maRE5gAKmfVkh1eDvhDWw4Ha9hvW9V81cNC5BVVVQj4=";
  };

  checkInputs = [
    pytest
    pytest-parametrized
  ];

  meta = with lib; {
    description = "Use operator overloading to create partially bound functions on-the-fly.";
    homepage = "https://github.com/coady/placeholder";
    license = licenses.asl20;
  };
}
