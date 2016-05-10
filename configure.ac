
AC_INIT([kbuild autoconf], 1.0)
AM_INIT_AUTOMAKE
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

AM_CONDITIONAL([ENABLE_NCONF], 
               [test x"${ax_cv_curses}" = x"yes" \
                  -a x"${ax_cv_panel}" = x"yes" \
                  -a x"${ax_cv_menu}" = x"yes" \
                  -a x"${ax_cv_form}" = x"yes"])

AC_CONFIG_FILES( 
                 Makefile
                 kconfig/Makefile
               )
AC_OUTPUT


