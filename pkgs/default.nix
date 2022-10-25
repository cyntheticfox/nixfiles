{ pkgs, lib, ... }@args:
with lib;
let
  containers = import ./containers args;
in
{
  ungoogled-chromium = pkgs.writeShellApplication "ungoogled-chromium.sh" ''
    ${pkgs.podman}/bin/podman run --tty --interactive \
      -v "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"="/tmp/$WAYLAND_DISPLAY" \
      -e WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
      docker-archive:${containers.oci-ungoogled-chromium}
  '';
}

