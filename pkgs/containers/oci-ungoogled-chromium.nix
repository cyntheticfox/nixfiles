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
  userName = "user";
  # -v "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" = "/tmp/$WAYLAND_DISPLAY";
  # -e WAYLAND_DISPLAY = "$WAYLAND_DISPLAY";
in
pkgs.dockerTools.buildImage {
  name = "chromium";

  runAsRoot = ''
    ${pkgs.coreutils}/bin/mkdir "/home" "/etc"
    ${pkgs.shadow}/bin/groupadd "${userName}"
    ${pkgs.shadow}/bin/useradd -g "${userName}" -m -d "/home/${userName}" "${userName}"
  '';

  config = {
    Cmd = [ "${pkgs.ungoogled-chromium}/bin/chromium" ];
    Memory = toGiB 2;
    Env = toEnv {
      XDG_RUNTIME_DIR = "/tmp";
    };
    Volumes = {
      "/home/${userName}" = { };
    };
    User = "${userName}:${userName}";
  };
}
