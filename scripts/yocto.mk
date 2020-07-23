## ////////////////////////////////////////////////////////////////////////// //
##
## This file is part of the autoconf-bootstrap project.
## Copyright 2018 Andrea Rigoni Garola <andrea.rigoni@igi.cnr.it>.
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.
##
## ////////////////////////////////////////////////////////////////////////// //


################################################################################
# Yocto download
################################################################################

if !YOCTO_DOCKERBUILD
NODOCKERBUILD += yocto%
endif

if ENABLE_YOCTO
yocto: ##@yocto download and prepare yocto poky build environment
YOCTO_DIR ?= $(abs_top_builddir)/yocto

DOWNLOADS += yocto
yocto_DIR    := $(YOCTO_DIR)
yocto_URL    := $(YOCTO_URL)
yocto_BRANCH := $(YOCTO_GIT_BRANCH)

YOCTO_BITBAKE_BINDIR = $(YOCTO_DIR)/bitbake/bin

YOCTO_BUILD = $(abs_builddir)/yocto-build
YOCTO_PYBIN_PATH = $(YOCTO_BUILD)/python-bin

$(YOCTO_PYBIN_PATH):
	@ $(MKDIR_P) $@

$(YOCTO_PYBIN_PATH)/python: |$(YOCTO_PYBIN_PATH)
	@ $(LN_S) /usr/bin/python2 $@

$(YOCTO_PYBIN_PATH)/python-config: |$(YOCTO_PYBIN_PATH)
	@ $(LN_S) /usr/bin/python2-config $@

YOCTO_PY2_LINKS =  \
   $(YOCTO_PYBIN_PATH)/python \
   $(YOCTO_PYBIN_PATH)/python-config

ak__DIRECTORIES += $(YOCTO_BUILD)

yocto-py2-link: ##@yocto build links for python2
yocto-py2-link: | $(YOCTO_BUILD) $(YOCTO_PY2_LINKS)


export abs_top_builddir abs_top_srcdir

ak__DOCKER_TARGETS += yocto-%
yocto-%: export BDIR = $(YOCTO_BUILD)
# yocto-%: DOCKER_CONTAINER ?= yocto-builder
# yocto-%: DOCKER_IMAGE     ?= crops/yocto:ubuntu-18.04-builder
yocto-%: export LANG=en_US.UTF-8


yocto-shell: ##@yocto enter shell
yocto-shell: PATH := $(abs_top_builddir)/$(YOCTO_PYBIN_PATH):$(abs_top_builddir)/$(YOCTO_BITBAKE_BINDIR):$(PATH)
yocto-shell: DOCKER_PS1 = \\u@\h:yocto \\W]\\$$
yocto-shell: yocto-py2-link
	@ cd $(YOCTO_DIR); . ./oe-init-build-env; bash;

yocto-image-minimal: ##@yocto image minimal
yocto-build-minimal: PATH := $(abs_top_builddir)/$(YOCTO_PYBIN_PATH):$(abs_top_builddir)/$(YOCTO_BITBAKE_BINDIR):$(PATH)
yocto-image-minimal: yocto-py2-link
	@ cd $(YOCTO_DIR); . ./oe-init-build-env; bitbake core-image-minimal;

yocto-bash:
	bash

#bash --rcfile <(echo PS1="$(PS1) ")

endif
