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

AM_DEFAULT_VERBOSITY = $(VERBOSE_LEVEL)

# VERBOSITY VARIABLE that is usable in Makefile if clause
# See Automake AM_V_P for comparison in bash if clauses
AK_V_IF    = $(ak__v_IF_$(V))
ak__v_IF_  = $(ak__v_IF_$(AM_DEFAULT_VERBOSITY))
ak__v_IF_0 = mark 
ak__v_IF_1 =

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

# FLAT NAME SUBST
# ---------------
ak__flt ?= $(subst -,_,$(subst ' ',_,$(subst .,_,$1)))

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
	@ $(MAKE) $(AM_MAKEFLAGS) download NAME=$1 DOWNLOAD_DIR=$(DOWNLOAD_DIR)
)
endef
$(foreach x,$(ak__DOWNLOADS),$(eval $(call dl__dir,$x)))

# $(ak__DOWNLOADS): _flt = $(subst -,_,$(subst ' ',_,$(subst .,_,$1)))
$(ak__DOWNLOADS): 
	@ $(MAKE) $(AM_MAKEFLAGS) download NAME=$@ DOWNLOAD_DIR=$(DOWNLOAD_DIR)

.PHONY: download
download: ##@@miscellaneous download target in $NAME and $DOWNLOAD_URL
download: FNAME   = $(subst -,_,$(subst ' ',_,$(subst .,_,$(NAME))))
download: URL     = $(or $($(FNAME)_URL),$(DOWNLOAD_URL))
download: DIR     = $(or $($(FNAME)_DIR),$(NAME))
download: BRANCH  = $(or $($(FNAME)_BRANCH),$(BRANCH))
download: $(or $($(FNAME)_DEPS), $(DOWNLOAD_DEPS))
	@ $(foreach x,$(URL), $(info DOWNLOAD_DIR = $(DOWNLOAD_DIR))\
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
## //  DISTFILES  /////////////////////////////////////////////////////////////////
## ////////////////////////////////////////////////////////////////////////////////

DISTFILES = $(DIST_COMMON) $(DIST_SOURCES) $(TEXINFOS) $(EXTRA_DIST) $(ak__DIST_COMMON)

ak__DIST_COMMON = \
                  $(top_srcdir)/bootstrap \
				  $(top_srcdir)/conf/update_submodules.sh \
				  $(top_srcdir)/Kconfig \
				  ## this line defines all kconfig files that exists (wildcard trick) from used .ac deps
				  $(wildcard $(patsubst %.ac,%.kconfig,$(filter %.ac,$(am__aclocal_m4_deps))))


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
IDE ?= code
edit: ##@miscellaneous start editor define in $IDE
edit: $(edit_DEPS) edit-$(IDE)
endif




# ////////////////////////////////////////////////////////////////////////////////
# //  ATOM  //////////////////////////////////////////////////////////////////////
# ////////////////////////////////////////////////////////////////////////////////


## ATOM_DEV_RESOURCE_PATH ?=
ATOM_HOME         ?= $(abs_top_builddir)/conf/ide/atom
ATOM_PROJECT_PATH ?= $(top_srcdir) $(builddir)

ak__ATOM_PACKAGES  = $(ATOM_PACKAGES)
ak__ATOM_PACKAGES += project-manager \
                     atom-ide-ui ide-python \
				     teletype \
				     refactor \
				     autocomplete-clang goto \
				     build build-make

#ak__PYTHON_PACKAGES += setuptools python-language-server[all]


export ATOM_HOME

ATOM_PACKAGES_PATH = $(addprefix $(ATOM_HOME)/packages/,$(ak__ATOM_PACKAGES))
$(ATOM_PACKAGES_PATH):
	@ apm install $(notdir $@)

apm-list: ##@@atom apm list packages in $ATOM_HOME
apm-%: | $(ATOM_HOME)
	@ apm $*

apm-install: ##@@atom apm install packages in $ATOM_HOME
apm-install: $(ATOM_PACKAGES_PATH)


ak__DIRECTORIES += $(ATOM_HOME)
edit-atom: ##@@ide start atom
edit-atom: | apm-install
	@ atom $(foreach d,$(ATOM_PROJECT_PATH),-a $d )


# ////////////////////////////////////////////////////////////////////////////////
# //  EMACS  /////////////////////////////////////////////////////////////////////
# ////////////////////////////////////////////////////////////////////////////////

edit-emacs: ##@@ide start emacs
edit-emacs:
	@ emacs $(srcdir)


# ////////////////////////////////////////////////////////////////////////////////
# //  QTCREATOR  /////////////////////////////////////////////////////////////////
# ////////////////////////////////////////////////////////////////////////////////


ak__QTCREATOR_SETTINGS_PATH = $(or $(QTCREATOR_SETTINGS_PATH),$(abs_top_builddir)/conf/ide)
QTCREATOR_THEME ?= dark
QTCREATOR_COLOR ?= Inkpot
ak__DIRECTORIES += $(ak__QTCREATOR_SETTINGS_PATH)
edit-qtcreator: ##@@ide start qtcreator
edit-qtcreator: | $(ak__QTCREATOR_SETTINGS_PATH)
	@ qtcreator -settingspath $(ak__QTCREATOR_SETTINGS_PATH) \
					-theme $(QTCREATOR_THEME) -color $(QTCREATOR_COLOR)


# ////////////////////////////////////////////////////////////////////////////////
# //  QWS  ///////////////////////////////////////////////////////////////////////
# ////////////////////////////////////////////////////////////////////////////////
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

# ////////////////////////////////////////////////////////////////////////////////
# //  VS CODE  ///////////////////////////////////////////////////////////////////
# ////////////////////////////////////////////////////////////////////////////////

ak__VS_CODE_PATH          = $(or $(VS_CODE_PATH),$(abs_top_builddir)/conf/ide/vs_code)
ak__VS_CODE_ARGS          = $(VS_CODE_ARGS)
ak__VS_CODE_PROJECT_PATH  = $(or $(VS_CODE_PROJECT_PATH),$(top_srcdir))
ak__VS_CODE_EXTENSIONS    = ms-vscode.cpptools \
							ms-python.python \
							maelvalais.autoconf \
							$(VS_CODE_EXTENSIONS)

if IDE_CODE_LOCAL_EXTENSIONS
ak__VS_CODE_EXTENSIONS_PATH = --extensions-dir=$(IDE_CODE_LOCAL_EXTENSIONS_PATH)
endif

ak__DIRECTORIES += $(ak__VS_CODE_PATH)

## export ELECTRON_FORCE_WINDOW_MENU_BAR = 1



if IDE_CODE_LOCAL ## IDE custom folder

ak__DIRECTORIES += $(IDE_CODE_LOCAL_DIR)
$(IDE_CODE_LOCAL_DIR)/bin/code: | $(DOWNLOAD_DIR) $(IDE_CODE_LOCAL_DIR) 
	- curl -SL $(IDE_CODE_DOWNLOAD_URL) > $(DOWNLOAD_DIR)/vs_code_local.tar.gz; \
	$(call dl__download_tar,$(DOWNLOAD_DIR)/vs_code_local.tar.gz,$(IDE_CODE_LOCAL_DIR)); \
	[ -f $@          ] && patch $@ < $(kconfig_dir)/patch/vs_code_libxcb.patch; \
	[ -f $@-insiders ] && patch $@-insiders < $(kconfig_dir)/patch/vs_code_insiders_libxcb.patch; \
	[ -f $@-insiders ] && ln -s $@-insiders $@; 

edit-code: ##@@ide start visual studio code editor
edit-code: ##@@vs_code start visual studio code editor
edit-code: $(IDE_CODE_LOCAL_DIR)/bin/code
	$(IDE_CODE_LOCAL_DIR)/bin/code \
	 -n $(ak__VS_CODE_PROJECT_PATH)  --user-data-dir $(ak__VS_CODE_PATH) \
	 $(ak__VS_CODE_EXTENSIONS_PATH) $(ak__VS_CODE_ARGS) 

edit-code-ext: ##@@vs_code list visual studio extensions
edit-code-ext: $(IDE_CODE_LOCAL_DIR)/bin/code
	@ $(IDE_CODE_LOCAL_DIR)/bin/code --user-data-dir $(ak__VS_CODE_PATH) \
	  $(ak__VS_CODE_EXTENSIONS_PATH) $(ak__VS_CODE_ARGS) --list-extensions

edit-code-extinstall: ##@@vs_code install all visual studio extensions in $IDE_CODE_EXTENSIONS
edit-code-extinstall: $(IDE_CODE_LOCAL_DIR)/bin/code
	@ $(foreach x,$(ak__VS_CODE_EXTENSIONS),$(IDE_CODE_LOCAL_DIR)/bin/code \
	  --user-data-dir $(ak__VS_CODE_PATH) $(ak__VS_CODE_ARGS) \
	  $(ak__VS_CODE_EXTENSIONS_PATH) --install-extension $x;)

else ## IDE from system

edit-code: | $(ak__VS_CODE_PATH)
	@ code -n $(ak__VS_CODE_PROJECT_PATH)  --user-data-dir $(ak__VS_CODE_PATH) \
	 $(ak__VS_CODE_EXTENSIONS_PATH) $(ak__VS_CODE_EXTENSIONS_PATH) $(ak__VS_CODE_ARGS) \
	 --enable-proposed-api ms-vscode-remote.remote-ssh

edit-code-ext:
	@ code --user-data-dir $(ak__VS_CODE_PATH) $(ak__VS_CODE_EXTENSIONS_PATH) \
	 $(ak__VS_CODE_ARGS) --list-extensions

edit-code-extinstall:
	@ $(foreach x,$(ak__VS_CODE_EXTENSIONS),code --user-data-dir $(ak__VS_CODE_PATH) \
	 $(ak__VS_CODE_EXTENSIONS_PATH) $(ak__VS_CODE_ARGS) --install-extension $x;)

endif


# ////////////////////////////////////////////////////////////////////////////////
# //  CDR CODE SERVER  ///////////////////////////////////////////////////////////
# ////////////////////////////////////////////////////////////////////////////////

ak__CODE_SERVER_HOST = $(or $(CODE_SERVER_HOST),0.0.0.0)
ak__CODE_SERVER_PORT = $(or $(CODE_SERVER_PORT),8080)
ak__CODE_SERVER_AUTH = $(or $(CODE_SEVER_AUTH),none)
ak__CODE_SERVER_URL  = $(or $(CODE_SERVER_URL),https://github.com/cdr/code-server/releases/download/3.4.1/code-server-3.4.1-linux-x86_64.tar.gz)
ak__DOWNLOADS += ak__cdr-code-server
ak__cdr-code-server: 
ak__cdr_code_server_URL = $(ak__CODE_SERVER_URL)
ak__cdr_code_server_DIR = $(top_builddir)/conf/ide/code-server

edit-code-server: ##@@ide start cdr vs code server installed in conf/code-server
edit-code-server: ak__cdr-code-server
	$(ak__cdr_code_server_DIR)/code-server --host $(ak__CODE_SERVER_HOST) --port $(ak__CODE_SERVER_PORT) --auth $(ak__CODE_SERVER_AUTH) \
	--user-data-dir $(ak__VS_CODE_PATH) $(ak__VS_CODE_EXTENSIONS_PATH) $(top_srcdir)





# /////////////////////////////////////////////////////////////////////////////
# // RECONFIGURE  /////////////////////////////////////////////////////////////
# /////////////////////////////////////////////////////////////////////////////

.PHONY: reconfigure
reconfigure: ##@miscellaneous re-run configure with last passed arguments
	@ \
	$(info \n\n -- Reconfiguring build directory: -----------") \
	cd '$(abs_top_builddir)' && ./config.status --recheck


shell: ##@miscellaneous start a $(SHELL) using make context
shell:
	$(SHELL)

print-env-: ##@@miscellaneous print-env-% print env variable
print-env-%:
	@ $(if $($*),$(info $*="$($*)"),$(info $* not set)):;


