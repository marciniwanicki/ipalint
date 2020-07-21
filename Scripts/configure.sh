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
    SWIFTLINT_FORMULA="https://raw.githubusercontent.com/Homebrew/homebrew-core/a150ab2162228b957db1871947315f2278b21252/Formula/swiftlint.rb"

    # 0.40.13
    SWIFTFORMAT_FORMULA="https://raw.githubusercontent.com/Homebrew/homebrew-core/cd3ba980c503d06fdc8daf796e2ddb795685b555/Formula/swiftformat.rb"

    # disable homebrew auto update
    export HOMEBREW_NO_AUTO_UPDATE=1

    # install (or reinstall) swiftlint
    install_formula swiftlint $SWIFTLINT_FORMULA

    # install (or reinstall) swiftformat
    install_formula swiftformat $SWIFTFORMAT_FORMULA
}

main
