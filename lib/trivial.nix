{
  # nz :: A? -> A -> A
  nz =
    # Value to check
    v:
    # Fallback value
    fallback:
    if v != null then v else fallback;
}
