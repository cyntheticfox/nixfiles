{ pkgs, ... }: {
  oci-ungoogled-chromium = pkgs.callPackage ./oci-ungoogled-chromium.nix { };
}
