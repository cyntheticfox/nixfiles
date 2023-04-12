{ lib, }: {
  # data NameValuePair = { name :: String, value :: Any }

  # mapListToAttrs :: (String -> Any) -> [String] -> AttrSet
  mapListToAttrs =
    # A function, given a string, that produces a corresponding value
    f:
    # The list of strings to map
    list:
    builtins.listToAttrs (builtins.map (n: lib.nameValuePair n (f n)) list);

  genAttrs = lib.flip mapListToAttrs;

  # mapListToAttrs' :: (A -> NameValuePair) -> [A] -> AttrSet
  mapListToAttrs' =
    # A function, given a value, that returns a `NameValuePair`
    f:
    # Values to map into resources
    list:
    builtins.listToAttrs (builtins.map f list);
}
