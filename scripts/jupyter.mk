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


if ENABLE_JUPYTER_NOTEBOOK

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

jpnb-start: ##@@jupyter start notebook server
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


jpnb-stop: ##@@jupyter stop notebook server
jpnb-stop:
	jupyter-notebook stop


jpnb-passwd: ##@@jupyter set new custom passwd
jpnb-passwd:
	jupyter-notebook password

endif