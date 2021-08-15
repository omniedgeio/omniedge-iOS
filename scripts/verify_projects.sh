#!/bin/zsh

set -euo pipefail

projects=(`find . -name project.pbxproj`)

for project in $projects
do
    python ./scripts/xUnique.py -spc $project > /dev/null
done
