#!/usr/bin/env zsh
#
# Zsh functions for git and such

function __is_git_repository() {
    git rev-parse --git-dir >/dev/null 2>&1

    return "$?"
}

function __msg_not_valid_repository() {
    echo "($1): Current directory is not a valid Git repository."
}

function push() {
    if __is_git_repository; then
        git push "$@"
    else
        __msg_not_valid_repository "push"
    fi
}

function pull() {
    if __is_git_repository; then
        git pull "$@"
    else
        __msg_not_valid_repository "pull"
    fi
}

function commit() {
    if __is_git_repository; then
        git commit --signoff "$@"
    else
        __msg_not_valid_repository "commit"
    fi
}

function commit-all() {
    if __is_git_repository; then
        git commit -a --signoff "$@"
    else
        __msg_not_valid_repository "commit-all"
    fi
}

function switch() {
    if __is_git_repository; then
        git switch "$@"
    else
        __msg_not_valid_repository "switch"
    fi
}

function stash() {
    if __is_git_repository; then
        git stash "$@"
    else
        __msg_not_valid_repository "stash"
    fi
}

function rebase() {
    if __is_git_repository; then
        git rebase '$@'
    else
        __msg_not_valid_repository "rebase"
    fi
}

function stage() {
    if __is_git_repository; then
        git add .
    else
        __msg_not_valid_repository "stage"
    fi
}

function unstage() {
    if __is_git_repository; then
        git unstage
    else
        __msg_not_valid_repository "unstage"
    fi
}

function state() {
    if __is_git_repository; then
        git state
    else
        __msg_not_valid_repository "state"
    fi
}

function github() {
    if [[ $# -eq 1 ]]; then
        git clone "github:$1.git"
    elif [[ $# -eq 2 ]]; then
        git clone "github:$1/$2.git"
    else
        echo "Usage: github <user> <repo>"
    fi
}

function gitlab() {
    if [[ $# -eq 1 ]]; then
        git clone "gitlab:$1.git"
    elif [[ $# -eq 2 ]]; then
        git clone "gitlab:$1/$2.git"
    else
        echo "Usage: gitlab <user> <repo>"
    fi
}

# Create Functions for NixOS
function nixupd() {
    if command -v nixos-rebuild &>/dev/null; then
        sudo nix-channel --update "$@"
    else
        nix-channel --update "$@"
    fi
}

function nixsw() {
    if command -v nixos-rebuild &>/dev/null; then
        sudo nixos-rebuild switch "$@"
    else
        home-manager switch "$@"
    fi
}
