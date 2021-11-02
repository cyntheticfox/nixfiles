{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    # Ansible
    ansible-lint

    # Bash/Shell
    shellcheck

    # C/C++
    cppcheck
    flawfinder

    # Clojure
    clj-kondo
    joker

    # Crystal
    ameba

    # CSS
    csslint
    nodePackages.stylelint

    # Dockerfile
    hadolint

    # General
    proselint
    vale

    # Gitcommit
    # BROKEN -- gitlint

    # Go
    golint

    # Haskell
    hlint

    # Java
    checkstyle
    pmd

    # Javascript
    nodePackages.eslint

    # JSON
    nodePackages.jsonlint

    # LUA
    luaPackages.luacheck

    # Markdown
    mdl

    # Nix
    statix

    # Python
    python39Packages.bandit
    python39Packages.flake8
    python39Packages.mypy
    python39Packages.pydocstyle
    python39Packages.pylama
    python39Packages.pylint
    pyright
    python39Packages.vulture

    # SQL
    sqlint

    # Terraform
    tflint

    # YAML
    yamllint
  ];
}
