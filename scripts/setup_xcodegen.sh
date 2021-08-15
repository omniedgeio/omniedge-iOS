#!/bin/bash

REQUIRED_XCODE_GEN_VERSION="Version: 2.23.1"

XCODE_GEN=$(which xcodegen)

XCODE_GEN_VERSION=$("$XCODE_GEN" version)

if [ "$XCODE_GEN_VERSION" = "$REQUIRED_XCODE_GEN_VERSION" ]; then
   echo "Already have required version. Congrats!"
   exit 0
fi

mint install yonaskolb/xcodegen@2.23.1
