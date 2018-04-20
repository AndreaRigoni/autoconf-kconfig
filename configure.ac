# ////////////////////////////////////////////////////////////////////////// //
#
# This file is part of the autoconf-bootstrap project.
# Copyright 2018 Andrea Rigoni Garola <andrea.rigoni@igi.cnr.it>.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# ////////////////////////////////////////////////////////////////////////// //


AC_INIT([kbuild autoconf], 1.0)
AM_INIT_AUTOMAKE
AC_CONFIG_MACRO_DIRS([m4])

AC_PROG_CC

AX_WITH_CURSES
AX_WITH_CURSES_PANEL
AX_WITH_CURSES_MENU
AX_WITH_CURSES_FORM

# try without ncursesw if it does not work
AS_IF([test x"${ax_cv_panel}" != xyes \
         -o x"${ax_cv_menu}" != xyes \
         -o x"${ax_cv_form}" != xyes],
      [AX_WITH_CURSES([ncurses])
       AX_WITH_CURSES_PANEL
       AX_WITH_CURSES_MENU
       AX_WITH_CURSES_FORM])

AS_IF([test x"${ax_cv_curses}" = x"yes" \
       -a x"${ax_cv_panel}" = x"yes" \
       -a x"${ax_cv_menu}" = x"yes" \
       -a x"${ax_cv_form}" = x"yes"],
	  [AS_VAR_SET([have_ncurses],[yes])],
      [AS_VAR_SET([have_ncurses],[no])])

AC_SUBST([HAVE_NCONF],[${have_ncurses}])
AM_CONDITIONAL([HAVE_NCONF], [test x"${have_ncurses}" = x"yes"])

AS_VAR_SET([KCONFIG_NCONF],[`pwd`/kconfig/nconf])
AC_SUBST([KCONFIG_NCONF])


AS_VAR_SET([KCONFIG_CONF],[`pwd`/kconfig/conf])
AC_SUBST([KCONFIG_CONF])


AC_CONFIG_COMMANDS([compile-kconfig],
		   [AC_MSG_NOTICE([compiling Kconfig])
		    $SHELL -c "make clean all V=0" > compile.log],
		   [])

AC_CONFIG_FILES( 
                 Makefile
                 kconfig/Makefile
               )
AC_OUTPUT


