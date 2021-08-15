#!/bin/bash

if [ -z "$1" ] ; then
    echo "Please provide the new module name"
    exit 1
fi

echo "Setting up module $1"

killall -3 Xcode

export PROJECT_NAME=$1
export PROJECT_DIR=Libraries/$1
export LC_CTYPE=C
export LANG=C

# Clean anything in the new module folder
# Then setup the new folder structure
rm -Rf $PROJECT_DIR
cp -r templates/module-starter Libraries
mv Libraries/module-starter $PROJECT_DIR

cd $PROJECT_DIR

# Rename templates to new name:

mv ___FILEBASENAME___ ${PROJECT_NAME}
mv ___FILEBASENAME___Tests ${PROJECT_NAME}Tests
mv ___FILEBASENAME___Demo ${PROJECT_NAME}Demo

find . -name "*___FILEBASENAME___*" | sed -e "p;s/___FILEBASENAME___/$PROJECT_NAME/" | xargs -n2 mv

# Rename {{ project_name }} in templates to $PROJECT_NAME

find ./ -type f -exec sed -i "" -e "s/{{ project_name }}/$PROJECT_NAME/g" {} \;

# Generate the project
xcodegen --spec module.yml

# Cleanup project scaffold
rm -f module.yml

cd ../../

export API_FILE=Libraries/OEPlatform/OEPlatform/ModulesAPI/${PROJECT_NAME}API.swift
export SH_PLATFORM=Libraries/OEPlatform/OEPlatform.xcodeproj
export APP_PROJECT=OmniedgeNew/OmniedgeNew.xcodeproj
#export TEST_PLAN=OmniedgeNew/AllTests.xctestplan

# Copy the new module API to the new place:

cp templates/platform-injection/___FILEBASENAME___API.swift $API_FILE

# Replace the template with the new project name

sed -i "" -e "s/{{ project_name }}/$PROJECT_NAME/g" $API_FILE

# Configure the workspace (add the API file and the new project to the main app)
./scripts/configure_workspace.rb $1

# Cleanup the projects
./scripts/clean_projects.sh

# Commit to git

git add $PROJECT_DIR $API_FILE $APP_PROJECT $TEST_PLAN
./scripts/git-add-matches.sh $SH_PLATFORM $1
git commit -m "Auto generated module $1" $API_FILE $SH_PLATFORM $PROJECT_DIR $APP_PROJECT $TEST_PLAN

echo "Setup complete - have fun!"
