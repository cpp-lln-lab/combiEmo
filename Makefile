.DEFAULT_GOAL := help

define BROWSER_PYSCRIPT
import os, webbrowser, sys

from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"

# determines what "make help" will show
define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

# TODO make more general to use the local matlab version
MATLAB = /usr/local/MATLAB/R2017a/bin/matlab
ARG    = -nodisplay -nosplash -nodesktop

################################################################################
#   General

.PHONY: help clean clean_demos clean_test update fix_submodule

help: ## Show what this Makefile can do
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean_test:	## Remove all the output of the tests
	rm *.log
	rm -rf coverage_html

fix_submodule: ## Fix any submodules that would not be checked out
	git submodule update --init --recursive && git submodule update --recursive

# TODO should update the version in
# - the doc conf.py
# - in the reference in the README
# - dockerfile
version.txt: CITATION.cff
	grep -w "^version" CITATION.cff | sed "s/version: /v/g" > version.txt

validate_cff: ## Validate the citation file
	cffconvert --validate

lint: ## Clean MATLAB code
	mh_style --fix && mh_metric --ci && mh_lint
