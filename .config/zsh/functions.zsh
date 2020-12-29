# functions.zsh
#
# Zsh functions for git and such

function push() {
    git push $@
}

function pull() {
    git pull $@
}

function commit() {
    git commit $@
}

function commit-all() {
    git commit -a $@
}

function stage() {
    git add .
}

function state() {
    git state
}

function github() {
    if [ $# -eq 1 ]; then
        git clone "github:$1.git"
    elif [ $# -eq 2 ]; then
        git clone "github:$1/$2.git"
    else
        echo "Usage: github <user> <repo>"
    fi
}
