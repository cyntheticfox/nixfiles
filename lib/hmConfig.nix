{ inputs
, username
, unstable ? false
, system ? "x86_64-linux"
, modules ? [ ]
}:
let
  home-manager =
    if
      unstable
    then
      inputs.home-manager-unstable
    else
      inputs.home-manager;
in
home-manager.lib.homeManagerConfiguration {
  inherit system username;

  homeDirectory = "/home/${username}";

  configuration = _: {
    imports = modules;
  };
}
