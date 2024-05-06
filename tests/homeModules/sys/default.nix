let
  listFilesInDir =
    dir:
    let
      dirAttr = builtins.readDir dir;
    in
    builtins.filter (n: dirAttr.${n} == "regular") (builtins.attrNames dirAttr);

  nixFilesInDir =
    dir:
    builtins.map (builtins.replaceStrings [ ".nix" ] [ "" ]) (
      builtins.filter (n: n != "default.nix") (listFilesInDir dir)
    );

  genAttrs' = fn: fv: builtins.foldl' (a: b: a // { "${fn b}" = fv b; }) { };

  genNixFileAttrs = fn: dir: genAttrs' fn (v: dir + "/${v}.nix") (nixFilesInDir dir);
in
genNixFileAttrs (n: "sys-${n}") ./.
