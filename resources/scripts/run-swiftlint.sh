#! /bin/sh

if [ -z "$CI" ]; then 
    unset SDKROOT
    set -e
    mint run SwiftLint lint
else
    echo "Note: SwiftLint is not expected to run during build phases on CI"
fi