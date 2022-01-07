{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    todo-txt-cli
  ];

  xdg.configFile."todo/config".text = ''
    # === EDIT FILE LOCATIONS BELOW ===

    # Your todo.txt directory (this should be an absolute path)
    export TODO_DIR=$(dirname "${config.xdg.userDirs.documents}/todo")

    # Your todo/done/report.txt locations
    export TODO_FILE="$TODO_DIR/todo.txt"
    export DONE_FILE="$TODO_DIR/done.txt"
    export REPORT_FILE="$TODO_DIR/report.txt"

    # You can customize your actions directory location
    export TODO_ACTIONS_DIR="${config.xdg.configHome}/todo/actions.d"
  '';


}
