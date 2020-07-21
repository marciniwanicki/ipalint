#!/bin/bash

source Scripts/common.sh

function main {
    # exit when any command fails
    set -e

    log_info "swiftlint version"
    swiftlint version

    log_info "swiftformat version"
	swiftformat --version

    # lint
    log_info "run swiftlint"
	swiftlint --strict --quiet

    # swiftformat
    log_info "run swiftformat"
	swiftformat . --lint
}

main
