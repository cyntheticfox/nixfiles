{ inputs
, pkgs
, outpkgs ? pkgs
, allowUnfree ? (!(builtins.getEnv "NIXOS_EXCLUDE_UNFREE" == "1"))
, isOverlay ? false
, ...
}:

with pkgs;

let result = let
  hasPath = attrset: path: lib.hasAttrByPath (lib.splitString "." path) attrset;
  resolvePath = attrset: path: lib.getAttrFromPath (lib.splitString "." path) attrset;
  resolveDep = path: if isOverlay then (resolvePath outpkgs path) else if (hasPath result path) then (resolvePath result path) else (resolvePath pkgs path);

  python3 = pkgs.python3.override {
    packageOverrides = self: super: super.pkgs.callPackage ./python-modules { };
  };

  python3Packages = recurseIntoAttrs python3.pkgs;
in {
  koneko = python3Packages.callPackage ./koneko { };

  # Add non-flakes
  comma = callPackage inputs.comma { };

  # Overrides
  firacode-nerdfont = nerdfonts.override { fonts = [ "FiraCode" ];};
  xow = xow.override {
    ### Override libusb1
    # Add a temporary workaround for high CPU use. I _could_ use a patch, but
    #   that's a lot of work.
    #
    # See https://github.com/medusalix/xow/issues/141
    #
    libusb1 = libusb1.overrideAttrs (oldAttrs: rec {
      version = "2022-01-03";

      src = fetchFromGitHub {
        owner = "libusb";
        repo = "libusb";
        rev = "f2b218b61867f27568ba74fa38e156e5f55ed825";
        sha256 = "sha256-P9nPP5fB43WI4TGKsztb2+Kye2G6KGZpj/Cr+btJSEc=";
      };

      patches = [ ];
    });
  };
  pass-wayland-ext = pass-wayland.withExtensions (e: with e; [ pass-otp pass-tomb ]);
} // (if isOverlay then {
  inherit python3Packages;
} else {
  python3Packages = recurseIntoAttrs (callPackage ./python-modules { });
}) // (lib.optionalAttrs allowUnfree {
  hyperchroma = callPackage ./hyperchroma { };
});
in result
