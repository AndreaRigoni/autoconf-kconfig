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

NODOCKERBUILD = help reconfigure
export DOCKER_NETWORKS   ?= bridge
export DOCKER_PS1

# Disable shared memory for QT exported display
export QT_X11_NO_MITSHM = 1


