# 'check_defined' auxilliary function via https://stackoverflow.com/a/10858332
#
# 'list' target via https://stackoverflow.com/a/26339924

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

list:
	@echo "Available targets:\n"
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs

clean: clean-boxes clean-tempfiles

clean-boxes:
	rm -f boxes/*.box

clean-cache:
	find build -name 'packer_cache' -exec rm -r {} \+

clean-tempfiles:
	find build -name 'Vagrantfile' -exec rm {} \+
	find build -name 'kickstart.cfg' -exec rm {} \+
	find build -name 'output-virtualbox-iso' -exec rm -r {} \+

clean-all: clean-boxes clean-cache clean-tempfiles

upload:
ifneq ($(wildcard boxes/*.box),)
	scp boxes/*.box unixfiles.int.its.rmit.edu.au:/var/www/html/boxes/
else
	@echo No boxes to upload.
endif

build-rhel6:
	$(call check_defined, VAGRANT_RHEL6_ORG VAGRANT_RHEL6_KEY)
	$(eval export BUILD_VERSION := $(shell date '+%Y%m%d_%H%M'))
	@sed -e "s/%VAGRANT_RHEL6_ORG%/${VAGRANT_RHEL6_ORG}/" \
		 -e "s/%VAGRANT_RHEL6_KEY%/${VAGRANT_RHEL6_KEY}/" \
		 build/rhel6/files/Vagrantfile.tmpl > \
		 build/rhel6/files/Vagrantfile
	@sed -e "s/%VAGRANT_RHEL6_ORG%/${VAGRANT_RHEL6_ORG}/" \
		 -e "s/%VAGRANT_RHEL6_KEY%/${VAGRANT_RHEL6_KEY}/" \
		 build/rhel6/http/kickstart.cfg.tmpl > \
		 build/rhel6/http/kickstart.cfg
	(cd build/rhel6 && packer build rhel6.json && mv *.box ../../boxes)
	@rm -f build/rhel6/files/Vagrantfile build/rhel6/http/kickstart.cfg

build-rhel7:
	$(call check_defined, VAGRANT_RHEL7_ORG VAGRANT_RHEL7_KEY)
	$(eval export BUILD_VERSION := $(shell date '+%Y%m%d_%H%M'))
	@sed -e "s/%VAGRANT_RHEL7_ORG%/${VAGRANT_RHEL7_ORG}/" \
		 -e "s/%VAGRANT_RHEL7_KEY%/${VAGRANT_RHEL7_KEY}/" \
		 build/rhel7/files/Vagrantfile.tmpl > \
		 build/rhel7/files/Vagrantfile
	@sed -e "s/%VAGRANT_RHEL7_ORG%/${VAGRANT_RHEL7_ORG}/" \
		 -e "s/%VAGRANT_RHEL7_KEY%/${VAGRANT_RHEL7_KEY}/" \
		 build/rhel7/http/kickstart.cfg.tmpl > \
		 build/rhel7/http/kickstart.cfg
	(cd build/rhel7 && packer build rhel7.json && mv *.box ../../boxes)
	@rm -f build/rhel7/files/Vagrantfile build/rhel7/http/kickstart.cfg

build-rhel8:
	$(call check_defined, VAGRANT_RHEL8_ORG VAGRANT_RHEL8_KEY)
	$(eval export BUILD_VERSION := $(shell date '+%Y%m%d_%H%M'))
	@sed -e "s/%VAGRANT_RHEL8_ORG%/${VAGRANT_RHEL8_ORG}/" \
		 -e "s/%VAGRANT_RHEL8_KEY%/${VAGRANT_RHEL8_KEY}/" \
		 build/rhel8/files/Vagrantfile.tmpl > \
		 build/rhel8/files/Vagrantfile
	@sed -e "s/%VAGRANT_RHEL8_ORG%/${VAGRANT_RHEL8_ORG}/" \
		 -e "s/%VAGRANT_RHEL8_KEY%/${VAGRANT_RHEL8_KEY}/" \
		 build/rhel8/http/kickstart.cfg.tmpl > \
		 build/rhel8/http/kickstart.cfg
	(cd build/rhel8 && packer build rhel8.json && mv *.box ../../boxes)
	@rm -f build/rhel8/files/Vagrantfile build/rhel8/http/kickstart.cfg

build-all: build-rhel6 build-rhel7 build-rhel8

.PHONY: list clean clean-boxes clean-cache clean-tempfiles clean-all upload build-all build-rhel6 build-rhel7 build-rhel8

