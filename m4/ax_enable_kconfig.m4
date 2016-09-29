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

  AX_GETVAR_SUBDIR([$1],[KCONFIG_CONF])
  AX_GETVAR_SUBDIR([$1],[KCONFIG_NCONF])

  AC_ARG_ENABLE([kconfig],
    [AS_HELP_STRING([--enable-kconfig=flavor],
      [Enable fancy configure with flavor in (conf | nconf) [[default=nconf]]])
    ],
    [AS_VAR_IF([enableval],[yes],
	       [AS_VAR_SET([enable_kconfig],[nconf])],
	       [AS_VAR_SET([enable_kconfig],[$enableval])])],
    [AS_VAR_SET_IF([ENABLE_KCONFIG],
		   [AS_VAR_SET([enable_kconfig],[${ENABLE_KCONFIG}])],
		   [AS_VAR_SET([enable_kconfig],[no])])]
  )

  AS_VAR_SET_IF([ENABLE_KCONFIG],
		[AS_VAR_SET([enable_kconfig],[${ENABLE_KCONFIG}])],
		[])

  AS_IF([test -t AS_ORIGINAL_STDIN_FD -o -p /dev/stdin],
  AS_ECHO([interactive console])
  AS_CASE([${enable_kconfig}],

	  # conf
	  [conf],
	  [$SHELL -c "srctree=${srcdir} ${KCONFIG_CONF} Kconfig" <&AS_ORIGINAL_STDIN_FD],

	  # nconf
	  [nconf],
	  [$SHELL -c "srctree=${srcdir} ${KCONFIG_NCONF} Kconfig" <&AS_ORIGINAL_STDIN_FD]))


  [ test -f .config ] && source ./.config
  AS_VAR_SET([subdirs],[$subdirs_SAVE])
])


AC_DEFUN([AX_KCONFIG_VAR],[
  m4_pushdef([_var_],[$1])
  AS_VAR_SET_IF(_var_,,AS_VAR_SET(_var_,${[CONFIG_]_var_[]}))
dnl  AC_SUBST(_var_)
  m4_popdef([_var_])
])

AC_DEFUN([AX_KCONFIG_CONDITIONAL],[
m4_pushdef([_var_],[$1])
AS_VAR_SET_IF(_var_,,AS_VAR_SET(_var_,${[CONFIG_]_var_[]}))
AM_CONDITIONAL(_var_, test x"${_var_}" = x"y")
dnl  AC_SUBST(_var_)
m4_popdef([_var_])
])
