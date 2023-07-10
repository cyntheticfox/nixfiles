(.nodes.root.inputs) as $inputs
  | .nodes
  | to_entries
  | map(
    select(.key | in($inputs))
    | [ .key
    , .value.locked.rev
    , .value.original.type
    , if .value.original.type == "github" then
        ( "https://api.github.com/repos/"
        + .value.original.owner
        + "/"
        + .value.original.repo
        + "/commits/"
        + (
            if .value.original.ref? then
              .value.original.ref
            elif .value.original.rev? then
              .value.original.rev
            else
              "HEAD"
            end
          )
        )
      elif .value.original.type == "gitlab" then
        ( "https://gitlab.com/api/v4/projects/"
        + .value.original.owner
        + "%2F"
        + .value.original.repo
        + "/repository/commits/"
        + (
            if .value.original.ref? then
              .value.original.ref
            elif .value.original.rev? then
              .value.original.rev
            else
              "HEAD"
            end
          )
        )
      else
        ("Bad type: \"" + .value.original.type + "\"")
      end
      ]
      | join(";")
    )
  | join(" ")

