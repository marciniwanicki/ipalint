#!/bin/bash

function main {
    # exit when any command fails
    set -e

    # test
    xcrun swift test --enable-code-coverage
}

main
