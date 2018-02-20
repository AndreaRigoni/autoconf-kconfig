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



MAKE_PROCESS  ?= $(shell grep -c ^processor /proc/cpuinfo)
DOWNLOAD_DIR  ?= $(top_builddir)/download
DOWNLOADS     ?=

## ////////////////////////////////////////////////////////////////////////// ##
## ///  DOWNLOAD  /////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

define dl__download_tar =
 $(info "Downloading tar file: $1")
 $(MKDIR_P) ${DOWNLOAD_DIR} $2; \
 _tar=${DOWNLOAD_DIR}/$$(echo $1 | sed -e 's|.*/||'); \
 test -f $$_tar || curl -SL $1 > $$_tar; \
 _wcl=$$(tar -tf $$_tar | sed -e 's|/.*||' | uniq | wc -l); \
 if test $$_wcl = 1; then \
  tar -xf $$_tar -C $2 --strip 1; \
 else \
  tar -xf $$_tar -C $2; \
 fi
endef

define dl__download_git =
 $(info "Downloading git repo: $1")
 git clone $1 $2 $(if $3,-b $3)
endef

define dl__download_generic =
 $(info "Downloading file: $1")
 $(MKDIR_P) ${DOWNLOAD_DIR}; \
 _f=${DOWNLOAD_DIR}/$$(echo $1 | sed -e 's|.*/||'); \
 test -f $$_f || curl -SL $1 > $$_f; \
 $(LN_S) $$_f $2;
endef

dl__tar_ext = %.tar %.tar.gz %.tar.xz %.tar.bz %.tar.bz2
dl__git_ext = git://% %.git

define dl__dir =
$(if $(filter-out $1,$($1_DIR)),
$($1_DIR): $$($1_DEPS)
	@ $(MAKE) $(AM_MAKEFLAGS) download NAME=$1
)
endef
$(foreach x,$(DOWNLOADS),$(eval $(call dl__dir,$x)))


# $(DOWNLOADS): _flt = $(subst -,_,$(subst ' ',_,$(subst .,_,$1)))
$(DOWNLOADS):
	@ $(MAKE) $(AM_MAKEFLAGS) download NAME=$@

.PHONY: download
download: ##@miscellaneous download target in $NAME and $DOWNLOAD_URL
download: FNAME   = $(subst -,_,$(subst ' ',_,$(subst .,_,$(NAME))))
download: URL     = $(or $($(FNAME)_URL),$(DOWNLOAD_URL))
download: DIR     = $(or $($(FNAME)_DIR),$(NAME))
download: BRANCH := $(or $($(FNAME)_BRANCH),$(BRANCH))
download: $(or $($(FNAME)_DEPS), $(DOWNLOAD_DEPS))
	@ $(foreach x,$(URL),\
		$(info Download: $x) \
		$(if $(filter $(dl__tar_ext),$x),$(call dl__download_tar,$x,$(DIR)), \
		$(if $(filter $(dl__git_ext),$x),$(call dl__download_git,$x,$(DIR),$(BRANCH)), \
		$(call dl__download_generic,$x,$(DIR)) ) ) \
	   )


