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



## /////////////////////////////////////////////////////////////////////////////
## // DOCKER  //////////////////////////////////////////////////////////////////
## /////////////////////////////////////////////////////////////////////////////

# docker build targets
@AX_DOCKER_BUILD_TARGETS@

NODOCKERBUILD = help reconfigure am__configure_deps

export DOCKER_NETWORKS   ?= bridge
export DOCKER_PS1

# Disable shared memory for QT exported display
export QT_X11_NO_MITSHM = 1


##    .########..##....##....########....###....########...######...########.########
##    .##.....##.##...##........##......##.##...##.....##.##....##..##..........##...
##    .##.....##.##..##.........##.....##...##..##.....##.##........##..........##...
##    .##.....##.#####..........##....##.....##.########..##...####.######......##...
##    .##.....##.##..##.........##....#########.##...##...##....##..##..........##...
##    .##.....##.##...##........##....##.....##.##....##..##....##..##..........##...
##    .########..##....##.......##....##.....##.##.....##..######...########....##...

export srcdir
export builddir
export top_srcdir
export top_builddir
export abs_top_srcdir
export abs_top_builddir


ak__DOCKER_TARGETS = $(DOCKER_TARGETS)

DSHELL = $(top_srcdir)/conf/dk.sh ${DSHELL_ARGS}
NO_DOCKER_TARGETS = Makefile $(srcdir)/Makefile.in $(srcdir)/Makefile.am $(top_srcdir)/configure.ac $(ACLOCAL_M4) $(top_srcdir)/configure am--refresh \
                    $(am__aclocal_m4_deps) $(am__configure_deps) $(top_srcdir)/%.mk \
					docker-%

# NODOCKERBUILD += Makefile $(srcdir)/Makefile.in $(srcdir)/Makefile.am $(top_srcdir)/configure.ac $(ACLOCAL_M4) $(top_srcdir)/configure am--refresh \
                    $(am__aclocal_m4_deps) $(am__configure_deps) $(top_srcdir)/%.mk \
					docker-%
NODOCKERBUILD += ${ak__DOCKER_TARGETS} #this is needed for build with docker
# DSHELL_ARGS = -v

if ENABLE_DOCKER_TARGETS

$(ak__DOCKER_TARGETS): export DOCKER_CONTAINER
$(ak__DOCKER_TARGETS): export DOCKER_IMAGE
$(ak__DOCKER_TARGETS): export DOCKER_URL
$(ak__DOCKER_TARGETS): export DOCKER_DOCKERFILE
$(ak__DOCKER_TARGETS): export DOCKER_SHARES
$(ak__DOCKER_TARGETS): export DOCKER_MOUNTS
$(ak__DOCKER_TARGETS): export DOCKER_PORTS
$(ak__DOCKER_TARGETS): export DOCKER_NETWORKS
$(ak__DOCKER_TARGETS): export DOCKER_DEVICES
$(ak__DOCKER_TARGETS): export DOCKER_SHELL = /bin/sh
$(ak__DOCKER_TARGETS): export DOCKER_REGISTRY
$(ak__DOCKER_TARGETS): export DOCKER_ENTRYPOINT



$(ak__DOCKER_TARGETS): override SHELL = $(DSHELL)
$(NO_DOCKER_TARGETS):  override SHELL = /bin/sh
$(NO_DOCKER_TARGETS):  override HAVE_DOCKER = no
endif



docker-clean: ##@@docker_target clean docker container conf in .docker directory
docker-start: ##@@docker_target start advanced per target docker container
docker-stop:  ##@@docker_target stop advanced per target docker container
docker-:      ##@@docker_target advanced per target docker (any command passed to conf/dk.sh)
docker-%:
	@ $(info [docker] $*)
	@ . $(DSHELL) $*



##    .##.....##....###.....######..##.....##.####.##....##.########
##    .###...###...##.##...##....##.##.....##..##..###...##.##......
##    .####.####..##...##..##.......##.....##..##..####..##.##......
##    .##.###.##.##.....##.##.......#########..##..##.##.##.######..
##    .##.....##.#########.##.......##.....##..##..##..####.##......
##    .##.....##.##.....##.##....##.##.....##..##..##...###.##......
##    .##.....##.##.....##..######..##.....##.####.##....##.########


export DOCKER_MACHINE
export DOCKER_MACHINE_ISO
export DOCKER_MACHINE_ARGS
export DOCKER_MACHINE_SORAGE_PATH ?= $(abs_top_builddir)/conf/.docker

NODOCKERBUILD += ${DOCKER_MACHINES} #this is needed for build with docker

$(DOCKER_MACHINES):
	@ $(MAKE) machine-create DOCKER_MACHINE=$@

docker-machine-%: DOCKER_CONTAINER = none
docker-machine-%: DOCKER_MACHINE_ARGS := $(or $($(DOCKER_MACHINE)_ARGS),$(DOCKER_MACHINE_ARGS))
docker-machine-%: DOCKER_MACHINE_ISO  := $(or $($(DOCKER_MACHINE)_ISO),$(DOCKER_MACHINE_ISO))
docker-machine-%: 
	$(DSHELL) machine_$*



NODOCKERBUILD += portainer-init docker-registry-init

portainer-init: ##@@docker_services poirtainer init (browse localhost:9000 then)
portainer-init: DOCKER_PORTAINER_PORT := $(or $(DOCKER_PORTAINER_PORT),9000)
portainer-init:
	@ docker volume create portainer_data; \
      docker run -d -p $(DOCKER_PORTAINER_PORT):9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer


docker-registry-init: ##@@docker_services registry init (provide an image registry at localhost:5000)
docker-registry-init: DOCKER_REGISTRY_PORT := $(or $(DOCKER_REGISTRY_PORT),5000)
docker-registry-init:
	@ docker service create --name registry --publish $(DOCKER_REGISTRY_PORT):5000 registry:2




