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


## ////////////////////////////////////////////////////////////////////////////////
## //  PYTHON  ////////////////////////////////////////////////////////////////////
## ////////////////////////////////////////////////////////////////////////////////

PYTHON_USERBASE         = $(abs_top_builddir)/conf/python/site-packages
ak__PYTHON_PACKAGES     = $(PYTHON_PACKAGES)
ac__PYTHON_REQUIREMENTS = $(PYTHON_REQUIREMENTS)


export PYTHONUSERBASE = $(PYTHON_USERBASE)
export PATH := $(PYTHON_USERBASE):$(PYTHON_USERBASE)/bin:$(PATH)
export PYTHONDONTWRITEBYTECODE=1

## export PYTHON_VERSION 
## ..... I can not export it because it breaks reconfiguration.. see issue #11

__py_init = $(__conda_init) $(__venv_init) 

# /////////////////////////////////////////////////
# //  VENV  ///////////////////////////////////////
# /////////////////////////////////////////////////

if PYTHON_ENV_SYSTEM_VENV
# PYTHON_VENV_ACTIVATE_SCRIPT = 
__venv_init = source $(PYTHON_VENV_ACTIVATE_SCRIPT); 
endif

# /////////////////////////////////////////////////
# //  CONDA  //////////////////////////////////////
# /////////////////////////////////////////////////

if PYTHON_ENV_SYSTEM_CONDA
PYTHON_CONDA_ENV ?= myenv
PYTHON_CONDA_DIR ?= $(HOME)/miniconda3
__conda_init = eval "$$($(PYTHON_CONDA_DIR)/bin/conda shell.bash hook)"; conda activate $(PYTHON_CONDA_ENV);
conda-envs:
	$(__conda_init) conda env list
endif



# /////////////////////////////////////////////////
# //  PIP  ////////////////////////////////////////
# /////////////////////////////////////////////////

ak__DIRECTORIES += $(PYTHON_USERBASE)

PYTHON_PIP_URL = https://bootstrap.pypa.io/get-pip.py
ak__get_pip: | $(DOWNLOAD_DIR)
	-@ $(__py_init) $(PYTHON) -c "import pip" 2>/dev/null || \
	{ curl -SL $(PYTHON_GETPIP_URL) > $(DOWNLOAD_DIR)/get-pip.py; \
	  $(__py_init) $(PYTHON) $(DOWNLOAD_DIR)/get-pip.py --user; }

# using python call fixes pip: https://github.com/pypa/pip/issues/7205
PIP := $(__py_init) $(PYTHON) -m pip

pip-install: ##@@python install prequired packages in $PYTHON_PACKAGES
pip-install: Q=$(if $(AK_V_IF),-q)

pip-list: ##@@python list packages
pip-list: __list_items=$(foreach x,$1,echo "| $x";)
pip-list: ak__get_pip | $(PYTHON_USERBASE)
	@ $(PIP) list; \
	  echo ""; echo " [ PYTHON_PACKAGES ] requested packages in Makefile "; \
	  echo ",-------------------------------------------------------"; \
	  $(call __list_items, ${ak__PYTHON_PACKAGES})

# targets executed before pip-install
ak__pre_pip_install  := $(pre_pip_install)

# targets executed after pip-install
ak__post_pip_install := $(post_pip_install)

pip-upgrade: ##@@python upgrade pip package version
pip-upgrade: $(ak__pre_pip_install) ak__get_pip | $(PYTHON_USERBASE)
	@ $(PIP) install $(Q) --upgrade --user \
	 pip setuptools wheel

pip-install: $(ak__pre_pip_install) ak__get_pip | $(PYTHON_USERBASE)
	@ $(PIP) install $(Q) --upgrade --user \
	 $(addprefix -r ,$(ac__PYTHON_REQUIREMENTS)) \
	 $(ak__PYTHON_PACKAGES); \
	 $(if $(ak__post_pip_install),$(MAKE) $(AM_MAKEFLAGS) $(ak__post_pip_install);)

pip-%: ak__get_pip | $(PYTHON_USERBASE)
	@ $(PIP) $* $(Q) --upgrade --user \
	 $(addprefix -r ,$(ac__PYTHON_REQUIREMENTS)) \
	 $(ak__PYTHON_PACKAGES)

# install prerequisites only once
pip_install_stamp = .pip-install.stamp
$(pip_install_stamp): $(ac__PYTHON_REQUIREMENTS) #$(srcdir)/Makefile.in 
	$(MAKE) $(AM_MAKEFLAGS) pip-install && touch $@

export REMOTE_DEBUG_HOST        ?= localhost
export REMOTE_DEBUG_GDB_PORT    ?= 3000
export REMOTE_DEBUG_PYTHON_PORT ?= 3001

ak__PYTHON_PACKAGES += setuptools python-language-server[all]
ak__PYTHON_PACKAGES += ptvsd

ak__PYTHON_scripts = $(PYTHON_SCRIPTS) $(foreach x,$(filter %_PYTHON,$(.VARIABLES)),$($x)) 

PYTHON_GDB   ?= gdbserver $(REMOTE_DEBUG_HOST):$(REMOTE_DEBUG_GDB_PORT)
PYTHON_PTVSD ?= -m ptvsd --host $(REMOTE_DEBUG_HOST) --port $(REMOTE_DEBUG_PYTHON_PORT) --wait

$(srcdir)/ipysh.py ipysh.py: $(top_srcdir)/conf/kconfig/scripts/ipysh.py
	-@cp $< $@ 

ipython: ##@python ipython shell
ipython: $(pip_install_stamp) ipysh.py 
	@ $(__py_init) $(PYTHON) -c "from IPython import start_ipython; start_ipython();"

py-run: ##@python run first script entry of $(NAME)_PYTHON variable of target $NAME
py-run: $(if $(NAME),$(addprefix $(srcdir)/,$($(NAME)_PYTHON))) $(NAME) $(ak__PYTHON_scripts) $(pip_install_stamp)
	@ $(__py_init) $(PYTHON) $<

py-ptvsd: ##@python run first script entry of $(NAME)_PYTHON under python debug
py-ptvsd: $(if $(NAME),$(addprefix $(srcdir)/,$($(NAME)_PYTHON))) $(NAME) $(ak__PYTHON_scripts) $(pip_install_stamp)
	@ $(__py_init) $(PYTHON) $(PYTHON_PTVSD) $<

py-gdb-ptvsd: ##@python run first script entry of $(NAME)_PYTHON under python debug and gdb
py-gdb-ptvsd: $(if $(NAME),$(addprefix $(srcdir)/,$($(NAME)_PYTHON))) $(NAME) $(ak__PYTHON_scripts) $(pip_install_stamp)
	@ $(__py_init) $(PYTHON_GDB) $(PYTHON) $(PYTHON_PTVSD) $<

# TODO:
# add dbg server un top
SUFFIXES = .ipynb .md

if ENABLE_JUPYTER_NOTEBOOK

export JUPYTERLAB_DIR = $(PYTHON_USERBASE)/share/jupyter
export JUPYTER_PATH   = $(PYTHON_USERBASE)/share/jupyter

ak__PYTHON_PACKAGES += jupyter jupyter-client jupyterlab
ak__PYTHON_PACKAGES += jupyter_contrib_nbextensions \
                       jupyter_nbextensions_configurator \
					   six

# post install nbextensions ( used for nbconvert )
ak__post_pip_install += jpnb-install-nbextensions
jpnb-install-nbextensions:
	$(__py_init) $(PYTHON) -m jupyter contrib nbextension install --user; \
	$(foreach x,$(JPNB_EXTENSIONS), $(__py_init) $(PYTHON) -m jupyter enable $x)


jp%-start: JPNB_CONFIG    := $(if $(JPNB_CONFIG),--config=$(JPNB_CONFIG))
jp%-start: JPNB_IP        := $(if $(JPNB_IP),--ip=$(JPNB_IP))
jp%-start: JPNB_PORT      := $(if $(JPNB_PORT),--port=$(JPNB_PORT))
jp%-start: JPNB_TRANSPORT := $(if $(JPNB_TRANSPORT),--transport=$(JPNB_TRANSPORT))
jp%-start: JPNB_BROWSER   := $(if $(JPNB_BROWSER),--browser=$(JPNB_BROWSER))
jp%-start: JPNB_DIR       := $(or $(JPNB_DIR),$(srcdir))
jp%-start: JPNB_DIR       := $(if $(JPNB_DIR),--notebook-dir=$(JPNB_DIR))
jp%-start: JPNB_PASSWD    := $(or $(JPNB_PASSWD),$(PASSWORD))
jp%-start: JPNB_PASSWD    := $(if $(JPNB_PASSWD),--NotebookApp.token=$(JPNB_PASSWD))



jpnb-start:  ##@python start jupyter notebook server
jpnb-stop:   ##@python stop notebook server
jplab-build: ##@python configure jupyter lab environment
jplab-start: ##@python start jupyter lab server
jpnb-passwd: ##@python set new custom passwd


ak__DIRECTORIES += .logs
jpnb-start: $(srcdir)/ipysh.py | .logs
	@ $(__py_init) $(PYTHON) -m jupyter notebook \
		--port-retries=0 \
		--NotebookApp.disable_check_xsrf=True \
		$(JPNB_CONFIG) \
		$(JPNB_IP) \
		$(JPNB_PORT) \
		$(JPNB_TRANSPORT) \
		$(JPNB_BROWSER) \
		$(JPNB_DIR) \
		$(JPNB_PASSWD) \
		>> .logs/notebook.log 2>&1 &


jplab-build: $(srcdir)/ipysh.py
	@ $(__py_init) $(PYTHON) -m jupyter lab build

jplab-start: $(srcdir)/ipysh.py
	@ $(__py_init) $(PYTHON) -m jupyter lab \
		--port-retries=0 \
		--NotebookApp.disable_check_xsrf=True \
		$(JPNB_CONFIG) \
		$(JPNB_IP) \
		$(JPNB_PORT) \
		$(JPNB_TRANSPORT) \
		$(JPNB_BROWSER) \
		$(JPNB_PASSWD) $(srcdir)


jpnb-stop:
	$(__py_init) $(PYTHON) -m jupyter notebook stop


jpnb-passwd:
	$(__py_init) $(PYTHON) -m jupyter notebook password



# /////////////////////////////////////////////////
# //  JP_NBCONVERT  ///////////////////////////////
# /////////////////////////////////////////////////


ak__PYTHON_PACKAGES += nbconvert nbcx
.ipynb.md: 
	$(__py_init) $(PYTHON) -m jupyter nbconvert --to markdown $<


endif
