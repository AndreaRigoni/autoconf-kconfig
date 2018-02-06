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



AC_DEFUN([AX_GITIGNORE_ADD],[
  AS_VAR_SET_IF([CONFIG_GIT_IGNORE],,AS_VAR_SET([CONFIG_GIT_IGNORE]))
  AS_VAR_APPEND([CONFIG_GIT_IGNORE],["
$1"])
])

AC_DEFUN([AX_GITIGNORE_ADD_PATH],[
  AS_VAR_SET_IF([CONFIG_GIT_IGNORE],,AS_VAR_SET([CONFIG_GIT_IGNORE]))  
  AS_VAR_SET([__ax_gitignore_var],[$(perl -e 'use File::Spec; print File::Spec->abs2rel(@ARGV) . "\n"' $1 ${srcdir})])
  AS_VAR_APPEND([CONFIG_GIT_IGNORE],["
/${__ax_gitignore_var}"])
])

AC_DEFUN([AX_GITIGNORE_ADD_ALLSUBDIR],[
  AX_GITIGNORE_ADD("**/"[]$1)
])


AC_DEFUN([AX_GITIGNORE_SUBST],[
  AC_PROG_SED
  AS_VAR_SET([CONFIG_GIT_IGNORE],[$(echo ${CONFIG_GIT_IGNORE} | sed -e"s/  */ /g")])
  AC_SUBST([CONFIG_GIT_IGNORE],["${CONFIG_GIT_IGNORE// /'
'}"])
  m4_ifdef([AM_SUBST_NOTMAKE], [AM_SUBST_NOTMAKE([CONFIG_GIT_IGNORE])])
])
