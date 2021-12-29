{ pkgs
, outpkgs ? pkgs
, allowUnfree ? (!(builtins.getEnv "NIXOS_EXCLUDE_UNFREE" == "1"))
, isOverlay ? false
, ...
}:

with pkgs;

let
  hasPath = attrset: path: lib.hasAttrByPath (lib.splitString "." path) attrset;
  resolvePath = attrset: path: lib.getAttrFromPath (lib.splitString "." path) attrset;
  resolveDep = path: if isOverlay then (resolvePath outpkgs path) else if (hasPath mypkgs path) then (resolvePath mypkgs path) else (resolvePath pkgs path);

  python3 = pkgs.python3.override {
    packageOverrides = self: super: super.pkgs.callPackage ./python-modules { };
  };

  python3Packages = recurseIntoAttrs python3.pkgs;
in
{
  koneko = python3Packages.callPackage ./koneko { };

  # Overrides
  firacode-nerdfont = nerdfonts.override { fonts = [ "FiraCode" ];};
  pass-wayland-ext = pass-wayland.withExtensions (e: with e; [ pass-otp pass-tomb ]);
} // (if isOverlay then {
  inherit python3Packages;
} else {
  python3Packages = recurseIntoAttrs (callPackage ./python-modules { });
}) // (lib.optionalAttrs allowUnfree {
  hyperchroma = callPackage ./hyperchroma { };
})
