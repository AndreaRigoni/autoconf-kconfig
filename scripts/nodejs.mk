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


NPM = $(NODEJS_NPM_BINARY)
NODE = $(NODEJS_NODE_BINARY)
CREATE_REACT_APP = $(CREATE_REACT_APP_BINARY)

NODE_PATH = $(NODEJS_MODULES_PATH)
NPM_CONFIG_PREFIX = $(NODEJS_MODULES_PATH)

RDIR        = $(abspath $(srcdir))
RDIR_NAME   = $(RDIR)/$(NAME)
ALL_MODULES = $(NODE_MODULES) $(REACT_MODULES)
NAME       ?= $(or $(lastword $(NODE_MODULES)), \
				   $(lastword $(REACT_MODULES)))
DEPS        = $($(subst -,_,$(NAME))_DEPS)


_DIRECTORIES = $(RDIR) \
			   $(RDIR_NAME) \
			   $(NODEJS_MODULES_PATH) \
			   $(RDIR_NAME)/node_modules/

$(_DIRECTORIES):
	@ $(MKDIR_P) $@

## /////////////////////////////////////////////////////////////////////////////
## //  INIT  ///////////////////////////////////////////////////////////////////
## /////////////////////////////////////////////////////////////////////////////


init: $(RDIR_NAME)/.init.stamp

.PHONY: $(NODE_MODULES) $(REACT_MODULES)
$(NODE_MODULES) $(REACT_MODULES):
	@ $(MAKE) $(AM_MAKEFLAGS) init NAME=$@

$(RDIR_NAME)/.init.stamp: npm-init
	@ touch $@


## /////////////////////////////////////////////////////////////////////////////
## //  DEPS  ///////////////////////////////////////////////////////////////////
## /////////////////////////////////////////////////////////////////////////////


$(addprefix $(RDIR_NAME)/node_modules/,$(ALL_MODULES)):
	@ $(info link: $@) \
	  cd $(RDIR_NAME); $(LN_S) $(RDIR)/$(notdir $@) $@

$(addprefix $(RDIR_NAME)/node_modules/,$(filter-out $(ALL_MODULES),$(DEPS))):
	@ $(info install: $@) \
	  cd $(RDIR_NAME); $(NPM) install $(notdir $@)

deps: | $(RDIR_NAME) $(RDIR_NAME)/node_modules/
	@ $(MAKE) $(AM_MAKEFLAGS) $(addprefix $(RDIR_NAME)/node_modules/,$(DEPS))

clean-deps:
	@ rm -rf $(RDIR_NAME)/node_modules

list: ##@npm list defined npm modules
list: _item = $(info | ${SH_YELLOW}$1:${SH_RESET}) \
			  $(foreach x,$($1),$(if $(filter-out $(NAME),$x),\
											   $(info |     $x),\
											   $(info |   * $x)))
list:
	@ \
	$(info ,-----------------------------------------------------------------) \
	$(info | ${SH_GREEN} use: make <target> NAME=<unit> ${SH_RESET} ) \
	$(info |) \
	$(call _item,NODE_MODULES) \
	$(info |) \
	$(call _item,REACT_MODULES) \
	$(info |) \
	$(call _item,$(NAME)_DEPS) \
	$(info |) \
	$(info `-----------------------------------------------------------------) :


## /////////////////////////////////////////////////////////////////////////////
## //  NODE  ///////////////////////////////////////////////////////////////////
## /////////////////////////////////////////////////////////////////////////////

node: $(RDIR) deps
	$(NODE) $(srcdir)/$(NAME).js $(NODE_ARGS)

js-name: ##@node start name.js script directly
js-%: %.js
	$(MAKE) $(AM_MAKEFLAGS) node NAME=$(subst js-,,$@)

## /////////////////////////////////////////////////////////////////////////////
## //  NPM  ////////////////////////////////////////////////////////////////////
## /////////////////////////////////////////////////////////////////////////////

npm-init: st = "$(if $(filter $(NAME),$(REACT_MODULES)), \
					 $(shell $(REACT_INIT_FUNC)))"
npm-init: NPM_ARGS = --yes

npm-start: ##@npm start app
npm-start: $(NAME) deps

npm-stop:  ##@npm stop app

npm-install: npm-update
npm-%: $(RDIR_NAME)
	@ $(info $(st)) \
	  cd $(RDIR_NAME); $(NPM) $(subst npm-,,$@) $(NPM_ARGS)


## /////////////////////////////////////////////////////////////////////////////
## //  REACT  //////////////////////////////////////////////////////////////////
## /////////////////////////////////////////////////////////////////////////////

if ENABLE_REACT
 REACT_INIT_FUNC ?= $(CREATE_REACT_APP) $(RDIR_NAME)
endif


