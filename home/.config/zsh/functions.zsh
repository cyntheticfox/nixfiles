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

function __clone_func() {
    echo "📦 Remote repository: $1"
    git clone $1
}

function __hosting_clone_func() {
    local HOST_USERNAME=""
    local HOST_URL=""

    HOST_USERNAME=$(git config --global --get "user.$1")

    if [[ $# -gt 1 ]]; then
        if [[ $# -eq 2 ]]; then
            if [[ "$2" =~ ^[a-zA-Z0-9\-]+$ ]]; then
                HOST_URL="$1:$HOST_USERNAME/$2.git"
            else
                HOST_URL= "$1:$2.git"
            fi
        else
            HOST_URL="$1:$2/$3.git"
        fi

        __clone_func "$HOST_URL"
    else
        echo "Repository name is required!"
        echo "Example: $1 your-repo-name"
        echo
        echo "Usages:"
        echo "  a) $1 username/repo-name"
        echo "  b) $1 username repo-name"
        echo "  c) $1 repo-name"
        echo "     For this, it's necessary to set your $1 username (login)"
        echo "     in your global config first, like:"
        echo "     git config --global user.$1 \"your-username\""
        echo
        echo "     You will also need to set your ssh config for $1 to use"
        echo "     any of these."
        echo
    fi
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
    __hosting_clone_func "github" $@
}

function gitlab() {
    __hosting_clone_func "gitlab" $@
}

function bitbucket() {
    __hosting_clone_func "bitbucket" $@
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
