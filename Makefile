# 'list' target via
# http://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile

list:
	@echo "Available targets:\n"
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs

clean: clean-boxes

clean-boxes:
	rm -f boxes/*.box

clean-cache:
	find build -name 'packer_cache' -exec rm -r {} \+

clean-all: clean-boxes clean-cache

upload:
ifneq ($(wildcard boxes/*.box),)
	scp boxes/*.box $(USER)@satlprdap01.int.its.rmit.edu.au:/var/www/html/boxes/
else
	@echo No boxes to upload.
endif

build-rhel6:
	$(eval export BUILD_VERSION := $(shell date '+%Y%m%d_%H%M'))
	(cd build/rhel6 && packer build rhel6.json && mv *.box ../../boxes)

build-rhel7:
	$(eval export BUILD_VERSION := $(shell date '+%Y%m%d_%H%M'))
	(cd build/rhel7 && packer build rhel7.json && mv *.box ../../boxes)

build-all: build-rhel6 build-rhel7

.PHONY: list clean clean-boxes clean-cache clean-all upload build-all build-rhel6 build-rhel7

