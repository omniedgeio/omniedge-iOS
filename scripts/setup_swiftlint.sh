#!/bin/bash

REQUIRED_LINT_VERSION=0.41.0

SWIFT_LINT=$(which swiftlint)

SWIFT_LINT_VERSION=$("$SWIFT_LINT" version)

if [ "$SWIFT_LINT_VERSION" = "$REQUIRED_LINT_VERSION" ]; then
   echo "Already have required version. Congrats! Now run swiftlint to lint your files."
   exit 0
fi

mint install realm/SwiftLint@0.41.0
