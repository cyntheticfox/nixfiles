{
  # contains :: [A] -> A -> bool
  contains = elem: builtins.any (x: elem == x);
}
