{ pkgs ? import <nixpkgs> { }
, ...
}: pkgs.dockerTools.buildImage {
  name = "chromium";
  config.Cmd = [ "${pkgs.ungoogled-chromium}/bin/chromium" ];
}
