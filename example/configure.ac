
AC_INIT([kbuild autoconf example], 1.0)
AC_CONFIG_MACRO_DIRS([m4])

AC_PROG_CC


dnl AX_KCONFIG /////////////////////////////////////////////////////////////////
dnl see: m4/ax_enable_kconfig.m4
AS_VAR_SET([srcdir],[${srcdir}])
AS_VAR_SET([builddir],[$(pwd)])
AX_KCONFIG([conf])


AX_KCONFIG_VAR_ENABLE([EXAMPLE_BOOL_VAR],["Set example bool var"])
AC_SUBST([CONFIG_EXAMPLE_BOOL_VAR])

AX_KCONFIG_VAR_WITH([EXAMPLE_STRING_VAR],["Set example string var"])
AC_SUBST([EXAMPLE_BOOL_VAR])


# //////////////////////////////////////////////////////////////////////////// #
# //  DOCKER BUILD /////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #

AS_VAR_IF([CONFIG_ENABLE_DOCKER_BUILD],[y],[
	   AS_VAR_SET_IF([CONFIG_DOCKER_CONTAINER],
	      [AS_VAR_SET([DOCKER_CONTAINER],[${CONFIG_DOCKER_CONTAINER}])] )
	   AS_VAR_SET_IF([CONFIG_DOCKER_IMAGE],
	      [AS_VAR_SET([DOCKER_IMAGE],[${CONFIG_DOCKER_IMAGE}])] )
	   AS_VAR_SET_IF([CONFIG_DOCKER_URL],
	      [AS_VAR_SET([DOCKER_URL],[${CONFIG_DOCKER_URL}])])
	  ])

AX_KCONFIG_VAR([DOCKER_SHARES])
AC_SUBST([DOCKER_SHARES])

# This is only an example of the actual configure.ac that uses kconfig vars,
# import ax_docker_build.m4 to use this feature in your project
#
# AX_DOCKER_BUILD


# //////////////////////////////////////////////////////////////////////////// #
# //  TOOLCHAIN  ///////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #

AX_KCONFIG_VAR_ENABLE([ENABLE_TOOLCHAIN],["Enable external toolchain"])
AX_KCONFIG_VAR_WITH([TOOLCHAIN_DIR],["Set toolchain base dir"])
AC_SUBST([TOOLCHAIN_DIR])

AX_KCONFIG_VAR_WITH([CROSS_COMPILE],["Set crosscompile command"])
AC_SUBST([CROSS_COMPILE])



AS_ECHO()
AS_BOX([// READ CONFIG VARIABLES //////], [\/])
AS_ECHO()
AS_ECHO("EXAMPLE_BOOL_VAR   ----> $EXAMPLE_BOOL_VAR")
AS_ECHO("EXAMPLE_STRING_VAR ----> $EXAMPLE_STRING_VAR")
AS_ECHO()



AC_CONFIG_FILES()
AC_OUTPUT


