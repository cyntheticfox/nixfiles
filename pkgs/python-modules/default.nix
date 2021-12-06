{ python3Packages }: with python3Packages; {
  pick = callPackage ./pick { };
  pixcat = callPackage ./pixcat { };
  pixivpy = callPackage ./pixivpy { };
  placeholder = callPackage ./placeholder { };
  pytest-parametrized = callPackage ./pytest-parametrized { };
  returns = callPackage ./returns { };
}
