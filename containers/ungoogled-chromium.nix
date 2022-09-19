{ pkgs
, lib
, ...
}:
let
  toKiB = builtins.mul 1024;
  toMiB = i: builtins.mul 1024 (toKiB i);
  toGiB = i: builtins.mul 1024 (toMiB i);
  toTiB = i: builtins.mul 1024 (toGiB i);
  toEnv = lib.mapAttrsToList lib.toShellVar;
in
pkgs.dockerTools.buildImage {
  name = "chromium";
  config = {
    Cmd = [ "${pkgs.ungoogled-chromium}/bin/chromium" ];
    Memory = toGiB 2;
    Env = toEnv {
      XDG_RUNTIME_DIR = /tmp;
      WAYLAND_DISPLAY = "$WAYLAND_DISPLAY";
    };
    Volumes = {
      "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" = "/tmp/$WAYLAND_DISPLAY";
    };
    User = "$(id -u):$(id -g)";
  };
}
