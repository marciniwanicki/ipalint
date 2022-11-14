#!/bin/bash -e

# Source helpers
source "${BASH_SOURCE%/*}/_common.sh"

PROJECT_DIR="$FIXTURES_DIR/$1"

# Go to project directory
pushd $PROJECT_DIR

# Source environment
source ".env"

# Build project
xcrun xcodebuild \
    -workspace "$XCB_WORKSPACE.xcworkspace" \
    -scheme "$XCT_SCHEME" \
    -configuration Debug \
    -destination "$XCT_DESTINATION" \
    -derivedDataPath .build \
    -sdk "$XCT_SDK"

# Go back
popd
