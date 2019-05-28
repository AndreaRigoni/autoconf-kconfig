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
ak__DOWNLOADS  = $(DOWNLOADS)
DOWNLOADS     ?= $(ak__DOWNLOADS)

# PERL ENV SUBST
# --------------
# This can be used to make a sh substitution template by calling $(call __ax_pl_envsubst, template, target)
#
# __ax_pl_envsubst ?= $(PERL) -pe 's/([^\\]|^)\$$\{([a-zA-Z_][a-zA-Z_0-9]*)\}/$$1.$$ENV{$$2}/eg' < $1 > $2
__ax_pl_envsubst  ?= $(PERL) -pe 's/([^\\]|^)\$$\{([a-zA-Z_][a-zA-Z_0-9]*)\}/$$1.$$ENV{$$2}/eg;s/\\\$$/\$$/g;' < $1 > $2
__ax_pl_envsubst2 ?= $(PERL) -pe 's/([^\\]|^)\$$\(([a-zA-Z_][a-zA-Z_0-9]*)\)/$$1.$$ENV{$$2}/eg;s/\\\$$/\$$/g;' < $1 > $2

# $(ak__ENVPARSEFILES):
# 	@ $(call __ax_pl_envsubst2,$<,$@);

# FILTER ALL REPETITIONS IN A LIST
# --------------------------------
ak__uniq ?= $(if $1,$(firstword $1) $(call ak__uniq,$(filter-out $(firstword $1),$1)))

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
$(foreach x,$(ak__DOWNLOADS),$(eval $(call dl__dir,$x)))

# $(ak__DOWNLOADS): _flt = $(subst -,_,$(subst ' ',_,$(subst .,_,$1)))
$(ak__DOWNLOADS):
	@ $(MAKE) $(AM_MAKEFLAGS) download NAME=$@

.PHONY: download
download: ##@@miscellaneous download target in $NAME and $DOWNLOAD_URL
download: FNAME   = $(subst -,_,$(subst ' ',_,$(subst .,_,$(NAME))))
download: URL     = $(or $($(FNAME)_URL),$(DOWNLOAD_URL))
download: DIR     = $(or $($(FNAME)_DIR),$(NAME))
download: BRANCH  = $(or $($(FNAME)_BRANCH),$(BRANCH))
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

ak__DIRECTORIES = $(DIRECTORIES)
$(ak__DIRECTORIES):
	@ $(info buildinf dir for: $@) $(MKDIR_P) $@


## INSTALL DIRECTORY AUTOMAKE OVERLOAD ////////////////////////////////////////////
#  USAGE: to install name as a whole directory add the following target:
#
#  install-<name>DATA:
# 	 @ $(MAKE) ak__$@
#
ak__install-%DATA:
	@$(NORMAL_INSTALL)
	@list='$($*_DATA)'; test -n "$($*dir)" || list=; \
	 if test -n "$$list"; then \
	   echo " $(MKDIR_P) '$(DESTDIR)$($*dir)'"; \
	   $(MKDIR_P) "$(DESTDIR)$($*dir)" || exit 1; \
	 fi; \
	 for p in $$list; do \
	   if test -f "$$p"; then echo "$$p"; \
	   else p="$(srcdir)/$$p"; \
	    if test -f "$$p"; then echo "$$p"; fi; \
	   fi; \
	 done | $(am__base_list) | \
	 while read files; do \
	   echo " $(INSTALL_DATA) $$files '$(DESTDIR)$($*dir)'"; \
	   $(INSTALL_DATA) $$files "$(DESTDIR)$($*dir)" || exit $$?; \
	 done; \
	 for p in $$list; do \
	   if test -d "$$p"; then echo "$$p"; \
	   else p="$(srcdir)/$$p"; \
	    if test -d "$$p"; then echo "$$p"; fi; \
	   fi; \
	 done | $(am__base_list) | \
	 while read drs; do \
	 	echo "copy directory: $$drs to $(DESTDIR)$($*dir)"; \
	 	cp -au $$drs "$(DESTDIR)$($*dir)"; \
	 done


## ////////////////////////////////////////////////////////////////////////////////
## //  CUSTOM MAKE  ///////////////////////////////////////////////////////////////
## ////////////////////////////////////////////////////////////////////////////////

if BUILD_CUSTOM_GNUMAKE

ak__DOWNLOADS += gnu-make
gnu_make_URL   = http://ftp.gnu.org/gnu/make/make-4.1.tar.gz
gnu_make_DIR   = $(BUILD_CUSTOM_GNUMAKE_DIR)

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

edit_DEPS =

if IDESUPPORT
IDE ?= qtcreator
edit: ##@miscellaneous start editor define in $IDE
edit: $(edit_DEPS) edit-$(IDE)
endif

## ////////////////////////////////////////////////////////////////////////////////
## //  PYTHON  ////////////////////////////////////////////////////////////////////
## ////////////////////////////////////////////////////////////////////////////////


PYTHON_USERBASE      = $(abs_top_builddir)/conf/python/site-packages
ac__PYTHON_PACKAGES  = $(PYTHON_PACKAGES)

export PYTHONUSERBASE = $(PYTHON_USERBASE)
export PATH := $(PYTHON_USERBASE):$(PYTHON_USERBASE)/bin:$(PATH)

ak__DIRECTORIES += $(PYTHON_USERBASE)
pip-install: ##@@python install prequired packages in $PYTHON_PACKAGES
pip-install: Q=-q
pip-list: ##@@python install prequired packages in $PYTHON_PACKAGES
pip-%: | $(PYTHON_USERBASE)
	@ pip $* $(Q) --upgrade --user $(ac__PYTHON_PACKAGES)

## ////////////////////////////////////////////////////////////////////////////////
## //  ATOM  //////////////////////////////////////////////////////////////////////
## ////////////////////////////////////////////////////////////////////////////////


## ATOM_DEV_RESOURCE_PATH ?=
ATOM_HOME         ?= $(abs_top_builddir)/conf/ide/atom
ATOM_PROJECT_PATH ?= $(top_srcdir) $(builddir)

ac__ATOM_PACKAGES  = $(ATOM_PACKAGES)
ac__ATOM_PACKAGES += project-manager \
                     atom-ide-ui ide-python \
				     teletype \
				     refactor \
				     autocomplete-clang goto \
				     build build-make

ac__PYTHON_PACKAGES += setuptools python-language-server[all]


export ATOM_HOME

ATOM_PACKAGES_PATH = $(addprefix $(ATOM_HOME)/packages/,$(ac__ATOM_PACKAGES))
$(ATOM_PACKAGES_PATH):
	@ apm install $(notdir $@)

apm-list: ##@@atom apm list packages in $ATOM_HOME
apm-%: | $(ATOM_HOME)
	@ apm $*

apm-install: ##@@atom apm install packages in $ATOM_HOME
apm-install: $(ATOM_PACKAGES_PATH)


ak__DIRECTORIES += $(ATOM_HOME)
edit-atom: ##@@ide start atom
edit-atom: | apm-install pip-install
	@ atom $(foreach d,$(ATOM_PROJECT_PATH),-a $d )


## ////////////////////////////////////////////////////////////////////////////////
## //  EMACS  /////////////////////////////////////////////////////////////////////
## ////////////////////////////////////////////////////////////////////////////////

edit-emacs: ##@@ide start emacs
edit-emacs:
	@ emacs $(srcdir)


## ////////////////////////////////////////////////////////////////////////////////
## //  QTCREATOR  /////////////////////////////////////////////////////////////////
## ////////////////////////////////////////////////////////////////////////////////


ak__QTCREATOR_SETTINGS_PATH = $(or $(QTCREATOR_SETTINGS_PATH),$(abs_top_builddir)/conf/ide)
QTCREATOR_THEME ?= dark
QTCREATOR_COLOR ?= Inkpot
ak__DIRECTORIES += $(ak__QTCREATOR_SETTINGS_PATH)
edit-qtcreator: ##@@ide start qtcreator
edit-qtcreator: | $(ak__QTCREATOR_SETTINGS_PATH)
	@ qtcreator -settingspath $(ak__QTCREATOR_SETTINGS_PATH) \
					-theme $(QTCREATOR_THEME) -color $(QTCREATOR_COLOR)


## ////////////////////////////////////////////////////////////////////////////////
## //  QWS  ///////////////////////////////////////////////////////////////////////
## ////////////////////////////////////////////////////////////////////////////////
##
## QWS are the qtcreator work spaces files.. they needs to be compiled with the
## absolute path so then a template is filled using the path discovered by
## autotools to create the correct project paths in qtcreator for "edit" target
#
%.qws: %.template.qws
	 @ $(call __ax_pl_envsubst,$<,$@);

qws: QWS_FILES_TEMPLATES = $(shell find $(top_srcdir)/conf/ide/QtProject/qtcreator/ -name '*.qws.template' 3>/dev/null)
qws: QWS_FILES = $(QWS_FILES_TEMPLATES:.qws.template=.qws)
qws: abs_top_srcdir := $(abs_top_srcdir)
qws: $(QWS_FILES)
edit_DEPS += qws

## ////////////////////////////////////////////////////////////////////////////////
## //  VS CODE  ///////////////////////////////////////////////////////////////////
## ////////////////////////////////////////////////////////////////////////////////

ak__VS_CODE_PATH          = $(or $(VS_CODE_PATH),$(abs_top_builddir)/conf/ide/vs_code)
ak__VS_CODE_PROJECT_PATH  = $(or $(VS_CODE_PROJECT_PATH),$(top_srcdir))
ak__DIRECTORIES += $(ak__VS_CODE_PATH)
edit-code: ##@@ide start visual studio code editor
edit-code: | $(ak__VS_CODE_PATH)
	@ code -n $(ak__VS_CODE_PROJECT_PATH)  --user-data-dir $(ak__VS_CODE_PATH)






