#!/bin/bash

function main {
    # exit when any command fails
    set -e

    # clean
    xcrun swift package clean
}

main
