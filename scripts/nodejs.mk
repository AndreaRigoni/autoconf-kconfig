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

# NODE_PATH = $(NODEJS_MODULES_PATH)
# NPM_CONFIG_PREFIX = $(NODEJS_MODULES_PATH)

NODE_PATH = $(RDIR_NAME)/node_modules
NPM_CONFIG_PREFIX = $(RDIR_NAME)
RDIR_NAME   = $(abspath $(srcdir))/$(NAME)

NAME       ?= $(lastword $(NODE_MODULES))
DEPS        = $($(subst -,_,$(NAME))_DEPS)

export RDIR_NAME
export NODE_PATH
export PATH := $(shell cd $(RDIR_NAME) && npm bin):$(PATH)
export DEPS

_DIRECTORIES = \
			   $(RDIR_NAME) \
			   $(RDIR_NAME)/node_modules/

$(_DIRECTORIES):
	@ $(MKDIR_P) $@

## /////////////////////////////////////////////////////////////////////////////
## //  INIT  ///////////////////////////////////////////////////////////////////
## /////////////////////////////////////////////////////////////////////////////


init: $(RDIR_NAME)/.init.stamp

$(NODE_MODULES):
	@ $(MAKE) $(AM_MAKEFLAGS) init NAME=$@

$(RDIR_NAME)/.init.stamp: npm-init
	@ touch $@


## /////////////////////////////////////////////////////////////////////////////
## //  DEPS  ///////////////////////////////////////////////////////////////////
## /////////////////////////////////////////////////////////////////////////////


$(addprefix $(RDIR_NAME)/node_modules/,$(NODE_MODULES)):
	@ $(info link: $@) \
	  cd $(RDIR_NAME); $(LN_S) $(RDIR)/$(or $(word 2, $(subst @, @,$@)), $(@F)) $@

$(addprefix $(RDIR_NAME)/node_modules/,$(filter-out $(NODE_MODULES),$(DEPS))):
	@ $(info install: $@) \
	  cd $(RDIR_NAME); $(NPM) install $(or $(word 2, $(subst @, @,$@)), $(@F))

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
	$(call _item,$(NAME)_DEPS) \
	$(info |) \
	$(info `-----------------------------------------------------------------) :


## /////////////////////////////////////////////////////////////////////////////
## //  NODE  ///////////////////////////////////////////////////////////////////
## /////////////////////////////////////////////////////////////////////////////


node: | deps
	$(NODE) $(srcdir)/$(NAME).js $(NODE_ARGS)

js-name: ##@@node start name.js script directly
js-%: %.js
	$(MAKE) $(AM_MAKEFLAGS) node NAME=$*

## /////////////////////////////////////////////////////////////////////////////
## //  NPM  ////////////////////////////////////////////////////////////////////
## /////////////////////////////////////////////////////////////////////////////

react-init: ##@@node init new react app
react-init: $(RDIR_NAME) deps
	@ create-react-app $(RDIR_NAME);

VUE_TEMPLATE ?= webpack-simple
vue-init: ##@@node init new vue app (adds @vue/cli-init)
vue-init: DEPS += @vue/cli-init
vue-init: $(RDIR_NAME) deps
	@ vue init $(VUE_TEMPLATE) $(NAME); $(MAKE) npm-install

npm-init: ##@@npm init new app
npm-init: NPM_ARGS = --yes
npm-init: $(RDIR_NAME)
	@ cd $(RDIR_NAME); $(NPM) init $(NPM_ARGS)

npm-start: ##@@npm start app
npm-start: $(NAME) deps

npm-stop:  ##@@npm stop app

npm-install: npm-update
npm-%: $(RDIR_NAME)
	@ cd $(RDIR_NAME); $(NPM) $* $(NPM_ARGS)



