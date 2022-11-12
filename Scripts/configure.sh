#!/bin/bash

source Scripts/common.sh

function install_formula {
    brew list $1 2> /dev/null
    if [[ $? == 0 ]] ; then
        log_info "uninstall $1"
        brew list "$1" && brew uninstall "$1"
    fi

    log_info "install $1"
    brew install --formula "$1.rb"
}

function main {
    # log brea version
    log_info "brew version"
    brew --version

    # disable homebrew auto update
    export HOMEBREW_NO_AUTO_UPDATE=1

    # go to Formulas directory
    pushd "Scripts/Formulas"

    # install (or reinstall) swiftlint
    install_formula swiftlint

    # install (or reinstall) swiftformat
    install_formula swiftformat

    # pop
    popd
}

main
