let
  moduleName = builtins.replaceStrings [ ".nix" "./" "/" ] [ "" "" "." ];
in
builtins.foldl' (a: b: a // b) { } (builtins.map (x: { "${moduleName (builtins.toString x)}" = import x; }) (import ./modules-list.nix))
