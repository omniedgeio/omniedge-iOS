#!/usr/bin/ruby
require 'xcodeproj'
require 'json'

project_name = ARGV[0]
api_file = "#{project_name}API.swift"
module_path = "Libraries/#{project_name}/#{project_name}.xcodeproj"
platform_path = 'Libraries/OEPlatform/OEPlatform.xcodeproj'
app_path = 'OmniedgeNew/OmniedgeNew.xcodeproj'

platform = Xcodeproj::Project.open(platform_path)

mainPlatform = platform.native_targets.find { |target| target.name == 'OEPlatform'  }
# Add the API file to the platform project:
fileRef = platform['OEPlatform/ModulesAPI'].new_file(api_file)
mainPlatform.add_file_references([fileRef])

platform.save()

# Add the module project file to the OmniedgeNew app
app = Xcodeproj::Project.open(app_path)
app['Libraries'].new_file(module_path).set_path("../#{module_path}")

# TODO - could add the project as a dependency as well

app.save()

# Add the test target to the test plan:

new_module = Xcodeproj::Project.open(module_path)

module_tests = new_module.native_targets.find { |target| target.name == "#{project_name}Tests"  }

new_test = {
    target: {
        containerPath: "container:../#{module_path}",
        identifier: module_tests.uuid,
        name: "#{project_name}Tests"
    }
}

tests_path = 'OmniedgeNew/AllTests.xctestplan'

test_plan = JSON.parse(File.read(tests_path))
test_plan["testTargets"] << new_test

options = {
    :space_before => ' ',
    :escape_slash => true
}
File.write(tests_path, JSON.pretty_generate(test_plan, options))
