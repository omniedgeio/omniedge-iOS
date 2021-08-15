#!/bin/bash
.PHONY : hook tools templates all
#.SILENT : init tools

NO_COLOR='\033[0m'
GREEN='\033[0;32m'

hook:
	git config core.hooksPath .githooks

tools:
	./scripts/setup_devtools.sh

templates:
	./scripts/setup_templates.sh

all: | hook tools templates
