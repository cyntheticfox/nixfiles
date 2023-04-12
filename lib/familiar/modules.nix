{ lib, ... }: {
  packageModule = { package, name, extraOptions ? { }, defaultEnable ? false }: lib.types.submodule (_: {
    options = {
      enable = lib.mkEnableOption "Enable ${name} configuration" // { default = defaultEnable; };

      package = lib.mkPackageOption pkgs package { };
    } // extraOptions;
  });

  multipackageModule = { description, defaultPackages ? [ ], defaultEnable ? false, extraOptions ? { } }: lib.types.submodule (_: {
    options = {
      enable = lib.mkEnableOption description // { default = defaultEnable; };

      packages = lib.mkOption {
        type = with lib.types; listOf package;
        default = defaultPackages;
      };
    } // extraOptions;
  });
}
