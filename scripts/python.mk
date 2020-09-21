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




ak__DIRECTORIES += $(PYTHON_USERBASE)

PYTHON_PIP_URL = https://bootstrap.pypa.io/get-pip.py
ak__get_pip: | $(DOWNLOAD_DIR)
	-@ $(PYTHON) -c "import pip" 2>/dev/null || { curl -SL $(PYTHON_GETPIP_URL) > $(DOWNLOAD_DIR)/get-pip.py; \
	$(PYTHON) $(DOWNLOAD_DIR)/get-pip.py --user; }

# using python call fixes pip: https://github.com/pypa/pip/issues/7205
PIP = $(PYTHON) -m pip

pip-install: ##@@python install prequired packages in $PYTHON_PACKAGES
pip-install: Q=$(if $(AK_V_IF),-q)

pip-list: ##@@python list packages
pip-list: __list_items=$(foreach x,$1,echo "| $x";)
pip-list: ak__get_pip | $(PYTHON_USERBASE)
	@ $(PIP) list; \
	  echo ""; echo " [ PYTHON_PACKAGES ] requested packages in Makefile "; \
	  echo ",-------------------------------------------------------"; \
	  $(call __list_items, ${ak__PYTHON_PACKAGES})

pip-%: ak__get_pip | $(PYTHON_USERBASE)
	@ $(PIP) $* $(Q) --upgrade --user \
	 $(addprefix -r ,$(ac__PYTHON_REQUIREMENTS)) \
	 $(ak__PYTHON_PACKAGES)

export REMOTE_DEBUG_HOST        ?= localhost
export REMOTE_DEBUG_GDB_PORT    ?= 3000
export REMOTE_DEBUG_PYTHON_PORT ?= 3001

ak__PYTHON_PACKAGES += setuptools python-language-server[all]
ak__PYTHON_PACKAGES += ptvsd

PYTHON_GDB   ?= gdbserver $(REMOTE_DEBUG_HOST):$(REMOTE_DEBUG_GDB_PORT)
PYTHON_PTVSD ?= -m ptvsd --host $(REMOTE_DEBUG_HOST) --port $(REMOTE_DEBUG_PYTHON_PORT) --wait

# # PYTHON_PACKAGES = debugpy
# debugpy: ##@mdsplus debug test program
# debugpy:
#         @ gdbserver localhost:5677 python $(srcdir)/mds_test.py
# 
# # @ gdbserver localhost:5677 python -m debugpy --listen 5678 --wait-for-client $(srcdir)/mds_test.py
# 
# debug_py: ##@mdsplus debug test only py
# debug_py:
#         @ python -m debugpy --listen 5678 --wait-for-client $(srcdir)/mds_test.py
# 
# debug_ptvsd: ##@mdsplus debug test only py
# debug_ptvsd: PYTHON_PACKAGES = ptvsd
# debug_ptvsd: pip-install
#         python -m ptvsd --host 0.0.0.0 --port $(or ${PORT},3000) --wait $(srcdir)/mds_test.py

ipysh.py: $(top_srcdir)/conf/kconfig/scripts/ipysh.py
	$(LN_S) $< $@

ipython: ##@python ipython shell
ipython: ipysh.py
	$(PYTHON) -c "from IPython import start_ipython; import ipysh; start_ipython();"

py-run: ##@python run first script entry of $(NAME)_PYTHON variable of target $NAME
py-run: $(if $(NAME),$(addprefix $(srcdir)/,$($(NAME)_PYTHON)))
	$(PYTHON) $<

py-ptvsd: ##@python run first script entry of $(NAME)_PYTHON under python debug
py-ptvsd: $(if $(NAME),$(addprefix $(srcdir)/,$($(NAME)_PYTHON)))
	$(PYTHON) $(PYTHON_PTVSD) $<

# TODO:
# add dbg server un top

if ENABLE_JUPYTER_NOTEBOOK

jpnb-start:  ##@jupyter start notebook server
jpnb-stop:   ##@jupyter stop notebook server
jpnb-passwd: ##@jupyter set new custom passwd


jpnb-start: JPNB_CONFIG    := $(if $(JPNB_CONFIG),--config=$(JPNB_CONFIG))
jpnb-start: JPNB_IP        := $(if $(JPNB_IP),--ip=$(JPNB_IP))
jpnb-start: JPNB_PORT      := $(if $(JPNB_PORT),--port=$(JPNB_PORT))
jpnb-start: JPNB_TRANSPORT := $(if $(JPNB_TRANSPORT),--transport=$(JPNB_TRANSPORT))
jpnb-start: JPNB_BROWSER   := $(if $(JPNB_BROWSER),--browser=$(JPNB_BROWSER))
jpnb-start: JPNB_DIR       := $(or $(JPNB_DIR),$(srcdir))
jpnb-start: JPNB_DIR       := $(if $(JPNB_DIR),--notebook-dir=$(JPNB_DIR))
jpnb-start: JPNB_PASSWD    := $(or $(JPNB_PASSWD),$(PASSWORD))
jpnb-start: JPNB_PASSWD    := $(if $(JPNB_PASSWD),--NotebookApp.token=$(JPNB_PASSWD))

ak__DIRECTORIES += .logs

jpnb-start: ##@@python start notebook server
jpnb-start: | .logs
	@ jupyter-notebook \
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


jpnb-stop: ##@@python stop notebook server
jpnb-stop:
	jupyter-notebook stop


jpnb-passwd: ##@@python set new custom passwd
jpnb-passwd:
	jupyter-notebook password

endif