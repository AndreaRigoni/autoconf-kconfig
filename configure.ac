
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
                   [AS_ECHO(["this is the command trigger to compile Kconfig"])
                    $SHELL -c "make all V=0"],
                   [])

AC_CONFIG_FILES( 
                 Makefile
                 kconfig/Makefile
               )
AC_OUTPUT


