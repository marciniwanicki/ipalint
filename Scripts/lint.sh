#!/bin/bash -e

source Scripts/common.sh

function main {
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
