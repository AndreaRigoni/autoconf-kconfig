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
DOWNLOAD_DIR  ?= $(top_builddir)/downloads
DOWNLOADS     =
DIRECTORIES   =

## ////////////////////////////////////////////////////////////////////////// ##
## ///  DOWNLOAD  /////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

define dl__download_tar
 $(info "Downloading tar file: $1") \
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

define dl__download_git
 $(info "Downloading git repo: $1") \
 git clone $1 $2 $(if $3,-b $3)
endef

define dl__download_generic
 $(info "Downloading file: $1") \
 $(MKDIR_P) ${DOWNLOAD_DIR}; \
 _f=${DOWNLOAD_DIR}/$$(echo $1 | sed -e 's|.*/||'); \
 test -f $$_f || curl -SL $1 > $$_f; \
 $(LN_S) $$_f $2;
endef


dl__tar_ext = %.tar %.tar.gz %.tar.xz %.tar.bz %.tar.bz2
dl__git_ext = git://% %.git

define dl__dir =
_fname = $(subst -,_,$(subst ' ',_,$(subst .,_,$1)))
$(if $(${_fname}_DIR),
$(${_fname}_DIR): $$(${_fname}_DEPS)
	@ $(MAKE) $(AM_MAKEFLAGS) download NAME=$1
)
endef
$(foreach x,$(DOWNLOADS),$(eval $(call dl__dir,$x)))

# $(DOWNLOADS): _flt = $(subst -,_,$(subst ' ',_,$(subst .,_,$1)))
$(DOWNLOADS):
	@ $(MAKE) $(AM_MAKEFLAGS) download NAME=$@

.PHONY: download
download: ##@@miscellaneous download target in $NAME and $DOWNLOAD_URL
download: FNAME   = $(subst -,_,$(subst ' ',_,$(subst .,_,$(NAME))))
download: URL     = $(or $($(FNAME)_URL),$(DOWNLOAD_URL))
download: DIR     = $(or $($(FNAME)_DIR),$(NAME))
download: BRANCH := $(or $($(FNAME)_BRANCH),$(BRANCH))
download: $(or $($(FNAME)_DEPS), $(DOWNLOAD_DEPS))
	@ $(foreach x,$(URL),\
		$(info Download: $x to $(DIR)) \
		$(if $(filter $(dl__tar_ext),$x),$(call dl__download_tar,$x,$(DIR)), \
		$(if $(filter $(dl__git_ext),$x),$(call dl__download_git,$x,$(DIR),$(BRANCH)), \
		$(call dl__download_generic,$x,$(DIR)) ) ) \
	   )

## ////////////////////////////////////////////////////////////////////////////////
## //  DIRECTORIES  ///////////////////////////////////////////////////////////////
## ////////////////////////////////////////////////////////////////////////////////

$(DIRECTORIES):
	@ $(MKDIR_P) $@


## ////////////////////////////////////////////////////////////////////////////////
## //  CUSTOM MAKE  ///////////////////////////////////////////////////////////////
## ////////////////////////////////////////////////////////////////////////////////

if BUILD_CUSTOM_GNUMAKE

DOWNLOADS += gnu-make
gnu_make_URL = http://ftp.gnu.org/gnu/make/make-4.1.tar.gz
gnu_make_DIR = $(BUILD_CUSTOM_GNUMAKE_DIR)

$(BUILD_CUSTOM_GNUMAKE_DIR)/Makefile: | gnu-make
	@ cd $(dir $@) && ./configure

$(BUILD_CUSTOM_GNUMAKE_DIR)/make: MAKE = make
$(BUILD_CUSTOM_GNUMAKE_DIR)/make: $(BUILD_CUSTOM_GNUMAKE_DIR)/Makefile
	@ make -C $(dir $@) all

_    = $(BUILD_CUSTOM_GNUMAKE_DIR)/make
MAKE = $(BUILD_CUSTOM_GNUMAKE_DIR)/make

endif


## ////////////////////////////////////////////////////////////////////////////////
## //  IDE  ///////////////////////////////////////////////////////////////////////
## ////////////////////////////////////////////////////////////////////////////////

if IDESUPPORT
IDE ?= atom
edit: ##@miscellaneous start editor define in $IDE
edit: edit-$(IDE)
endif

## ////////////////////////////////////////////////////////////////////////////////
## //  PYTHON  ////////////////////////////////////////////////////////////////////
## ////////////////////////////////////////////////////////////////////////////////


PYTHON_USERBASE = $(abs_top_builddir)/conf/python/site-packages
PYTHON_PACKAGES =

export PYTHONUSERBASE = $(PYTHON_USERBASE)

DIRECTORIES += $(PYTHON_USERBASE)
pip-install: ##@@python install prequired packages in $PYTHON_PACKAGES
pip-install: Q=-q
pip-list: ##@@python install prequired packages in $PYTHON_PACKAGES
pip-%: | $(PYTHON_USERBASE)
	@ pip $* $(Q) --user $(PYTHON_PACKAGES)

## ////////////////////////////////////////////////////////////////////////////////
## //  ATOM  //////////////////////////////////////////////////////////////////////
## ////////////////////////////////////////////////////////////////////////////////


## ATOM_DEV_RESOURCE_PATH ?=
ATOM_HOME         ?= $(abs_top_builddir)/conf/ide/atom
ATOM_PROJECT_PATH ?= $(top_srcdir) $(builddir)

ATOM_PACKAGES    = project-manager \
                   atom-ide-ui ide-python \
				   teletype \
				   refactor \
				   autocomplete-clang goto \
				   build build-make

PYTHON_PACKAGES += python-language-server[all]


export ATOM_HOME

ATOM_PACKAGES_PATH = $(addprefix $(ATOM_HOME)/packages/,$(ATOM_PACKAGES))
$(ATOM_PACKAGES_PATH):
	@ apm install $(notdir $@)

apm-list: ##@@atom apm list packages in $ATOM_HOME
apm-%: | $(ATOM_HOME)
	@ apm $*

apm-install: ##@@atom apm install packages in $ATOM_HOME
apm-install: $(ATOM_PACKAGES_PATH)

DIRECTORIES += $(ATOM_HOME)
edit-atom: ##@@ide start atom
edit-atom: | apm-install pip-install # $(srcdir)/.atom-build.yml
	@ atom $(foreach d,$(ATOM_PROJECT_PATH),-a $d )

## ATOM_BUILD_TARGETS ?= $(SELFHELP_TARGETS)
## $(srcdir)/.atom-build.yml: $(MAKEFILE_LIST)
## 	@ echo "targets:" > $@; \
## 	  for t in $(ATOM_BUILD_TARGETS); do \
## 	  echo "   $$t: " >> $@; \
## 	  echo "     cmd: make $$t " >> $@; \
## 	  done;
##
## edit-atom-build: ##@@ide create atom-build.yml file
## edit-atom-build: $(srcdir)/.atom-build.yml
CLEANFILES =
CLEANFILES += $(srcdir)/.atom-build.yml

.PHONY: list-all-targets
list-all-targets: ##@@miscellaneous list all available targets
list-all-targets:
	@ $(MAKE) -pRrq : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs





## ////////////////////////////////////////////////////////////////////////////////
## //  EMACS  /////////////////////////////////////////////////////////////////////
## ////////////////////////////////////////////////////////////////////////////////

edit-emacs: ##@@ide start emacs
edit-emacs:
	@ emacs $(srcdir)


## ////////////////////////////////////////////////////////////////////////////////
## //  QTCREATOR  /////////////////////////////////////////////////////////////////
## ////////////////////////////////////////////////////////////////////////////////


QTCREATOR_SETTINGS_PATH = $(abs_top_builddir)/conf/ide/qtcreator
QTCREATOR_THEME = dark
DIRECTORIES += $(QTCREATOR_SETTINGS_PATH)
edit-qtcreator: ##@@ide start qtcreator
edit-qtcreator: | $(QTCREATOR_SETTINGS_PATH)
	@ qtcreator -settingspath $(QTCREATOR_SETTINGS_PATH) \
	            -theme $(QTCREATOR_THEME)
