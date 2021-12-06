{ lib
, buildPythonPackage
, fetchFromGitHub
, pytest
}:

buildPythonPackage rec {
  pname = "pytest-parametrized";
  version = "1.3";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "coady";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-vGh9YOdLhMAFTM6wk3E1od6eLLwS0Ng3KvAB5n/lFBI=";
  };

  buildInputs = [ pytest ];

  meta = with lib; {
    description = "Pytest decorator for marametrizing tests with default itertables, providing alternative syntax for pytest.mark.parametrize";
    homepage = "https://github.com/coady/pytest-parametrized";
    license = licenses.asl20;
  };
}
