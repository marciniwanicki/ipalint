#!/bin/bash

function main {
    # exit when any command fails
    set -e

    # build
    swift build
}

main