#!/bin/bash

source Scripts/common.sh

function main {
    # exit when any command fails
    set -e

    # swiftformat
    log_info "run swiftformat"
    swiftformat .
}

main

