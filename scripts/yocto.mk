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
YOCTO_DIR ?= $(builddir)/yocto

DOWNLOADS += yocto
yocto_DIR    := $(YOCTO_DIR)
yocto_URL    := $(YOCTO_URL)
yocto_BRANCH := $(YOCTO_GIT_BRANCH)

YOCTO_BUILD = $(YOCTO_DIR)/build
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

yocto-py2-link: ##@yocto build links for python2
yocto-py2-link: $(YOCTO_DIR) $(YOCTO_PY2_LINKS)


yocto-shell: ##@yocto enter oe-init-build-env
yocto-shell: PATH := $(abs_top_builddir)/$(YOCTO_PYBIN_PATH):$(PATH)
yocto-shell: PS1  := \\u@\h:yocto \\W]\\$$
yocto-shell: yocto-py2-link
	@ cd $(YOCTO_DIR); source ./oe-init-build-env; \
	  bash -l

endif
