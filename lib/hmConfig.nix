{ self
, username
, system ? "x86_64-linux"
, modules ? [ ]
}:
self.inputs.home-manager.lib.homeManagerConfiguration {
  inherit system username;

  homeDirectory = "/home/${username}";

  configuration = _: {
    imports = modules ++ (builtins.attrValues self.outputs.homeModules);

    home.stateVersion = "22.05";
  };
}
