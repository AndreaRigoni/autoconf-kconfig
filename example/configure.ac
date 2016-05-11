
AC_INIT([kbuild autoconf example], 1.0)

# AX_GETVAR_SUBDIR
# -----------------
# subdir, var, [subvar] (if different from var)
AC_DEFUN([AX_GETVAR_SUBDIR],[
  m4_pushdef([subvar],[m4_default($3,$2)])
  AS_VAR_SET([$2],$(echo '@subvar@' | $1/config.status --file=-))
  m4_popdef([subvar])
])


# AX_KCONFIG
# ----------
# [kconfig-subdir]
AC_DEFUN([AX_KCONFIG],[
  AS_VAR_SET([subdirs_SAVE],[$subdirs])
  AS_VAR_SET([subdirs],[$1])
  _AC_OUTPUT_SUBDIRS
  AX_GETVAR_SUBDIR([$1],[KCONFIG_NCONF])
  $SHELL -c "${KCONFIG_NCONF} Kconfig" <&AS_ORIGINAL_STDIN_FD
  source ./.config
  AS_VAR_SET([subdirs],[$subdirs_SAVE])
])




AX_KCONFIG([conf])
AC_PROG_CC




AC_SUBST([CONFIG_EXAMPLE_BOOL_VAR])
AS_ECHO("CONFIG_EXAMPLE_BOOL_VAR ----> $CONFIG_EXAMPLE_BOOL_VAR")



AC_CONFIG_FILES()
AC_OUTPUT


