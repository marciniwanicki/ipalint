#!/bin/bash

source Scripts/common.sh

function install_formula {
    log_info "brew version"
    brew --version

    log_info "install $1"
    brew install "$2"
}

function main {
    # exit when any command fails
    set -e

    # 0.35.0
    SWIFTLINT_FORMULA="swiftlint.rb"

    # 0.40.13
    SWIFTFORMAT_FORMULA="swiftformat.rb"

    # disable homebrew auto update
    export HOMEBREW_NO_AUTO_UPDATE=1

    # go to Formulas directory
    pushd "Scripts/Formulas"

    # install (or reinstall) swiftlint
    install_formula swiftlint $SWIFTLINT_FORMULA

    # install (or reinstall) swiftformat
    install_formula swiftformat $SWIFTFORMAT_FORMULA

    # pop
    popd
}

main
