#!/bin/bash

cd scripts
./setup_swiftlint.sh
./setup_xcodegen.sh

echo "Installing gems. Your password might be required"

sudo gem install xcodeproj json
