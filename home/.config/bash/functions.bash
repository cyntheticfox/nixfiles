#!/usr/bin/env bash
#
# Bash functions for git and such

function push() {
    git push "$@"
}

function pull() {
    git pull "$@"
}

function commit() {
    git commit "$@"
}

function commit-all() {
    git commit -a "$@"
}

function rebase() {
    git rebase "$@"
}

function switch() {
    git switch "$@"
}

function stash() {
    git stash "$@"
}

function stage() {
    git add .
}

function unstage() {
    git unstage
}

function state() {
    git state
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
