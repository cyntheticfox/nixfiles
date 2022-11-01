{ inputs
, username
, system ? "x86_64-linux"
, modules ? [ ]
}:
inputs.home-manager.lib.homeManagerConfiguration {
  inherit system username;

  homeDirectory = "/home/${username}";

  configuration = _: {
    imports = modules;

    home.stateVersion = "22.05";
  };
}
