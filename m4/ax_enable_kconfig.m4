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
		   [AS_IF([test -f .config],,AS_VAR_SET([enable_kconfig],[default]))]
dnl		   [AS_VAR_SET([enable_kconfig],[no])]
		   )]
  )

  dnl this is needed by dockerbuild to disable kconfig (fix it)
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
	  [$SHELL -c "srctree=${srcdir} ${KCONFIG_NCONF} Kconfig" <&AS_ORIGINAL_STDIN_FD],

	  # create default .config
	  [default],
	  [$SHELL -c "srctree=${srcdir} ${KCONFIG_CONF} --alldefconfig Kconfig" <&AS_ORIGINAL_STDIN_FD],

	  # update
	  [update],
	  [$SHELL -c "srctree=${srcdir} ${KCONFIG_CONF} --savedefconfig .defconfig Kconfig" <&AS_ORIGINAL_STDIN_FD]

	 ))

  [ test -f .config ] && source ./.config
  AS_VAR_SET([subdirs],[$subdirs_SAVE])
])


AC_DEFUN_LOCAL([KCONFIG],[AX_KCONFIG_EXPAND_YN],[
  AS_CASE([$$1],
	  [y],AS_VAR_SET([$1],[yes]),
	  [n],AS_VAR_SET([$1],[no]))
])



# AX_KCONFIG_VAR(VAR)
# ------------------------------------------------------------------------
AC_DEFUN([AX_KCONFIG_VAR],[
  AC_PUSH_LOCAL([KCONFIG])
  m4_pushdef([_var_],[$1])
  AS_VAR_SET_IF(_var_,,AS_VAR_SET(_var_,${[CONFIG_]_var_[]}))
  m4_append_uniq([_KCONF_VARS],_var_,[ ])
  dnl  AC_SUBST(_var_)
  AC_POP_LOCAL([KCONFIG])
  m4_popdef([_var_])
])

# AX_KCONFIG_CONDITIONAL(VAR)
# ------------------------------------------------------------------------
AC_DEFUN([AX_KCONFIG_CONDITIONAL],[
  AC_PUSH_LOCAL([KCONFIG])
  m4_pushdef([_var_],[$1])
  AS_VAR_SET_IF(_var_,,[AS_VAR_SET(_var_,${[CONFIG_]_var_[]})]
		       [AX_KCONFIG_EXPAND_YN(_var_)])
  m4_append_uniq([_KCONF_VARS],_var_,[ ])
  AM_CONDITIONAL(_var_, test x"${_var_}" = x"yes")
  dnl  AC_SUBST(_var_)
  m4_popdef([_var_])
  AC_POP_LOCAL([KCONFIG])
])


# AX_KCONFIG_VAR_WITH(FEATURE, HELP, [ACTION-IF-TRUE], [ACTION-IF-FALSE])
# ------------------------------------------------------------------------
AC_DEFUN([AX_KCONFIG_VAR_WITH],[
  AC_PUSH_LOCAL([KCONFIG])
  m4_pushdef([_var_],m4_bpatsubst(m4_tolower(m4_translit([$1],[_-],[__])),[^with_],[]))
  AS_VAR_SET_IF([$1],,[AS_VAR_SET([$1],${[CONFIG_$1]})]
		      [AX_KCONFIG_EXPAND_YN([$1])])
  m4_append_uniq([_KCONF_VARS],[$1],[ ])
  AC_ARG_WITH(_var_,
	      [AS_HELP_STRING(--with-[]m4_translit(_var_,[_],[-]),[$2])],
	      [AS_VAR_SET([$1],${with_[]_var_})])
  m4_popdef([_var_])
  AC_POP_LOCAL([KCONFIG])
])


# AX_KCONFIG_VAR_ENABLE(FEATURE, HELP, [ACTION-IF-TRUE], [ACTION-IF-FALSE])
# ------------------------------------------------------------------------
AC_DEFUN([AX_KCONFIG_VAR_ENABLE],[
  AC_PUSH_LOCAL([KCONFIG])
  m4_pushdef([_var_],m4_bpatsubst(m4_tolower(m4_translit([$1],[_-],[__])),[^enable_],[]))
  AS_VAR_SET_IF([$1],,[AS_VAR_SET([$1],${[CONFIG_$1]})]
		      [AX_KCONFIG_EXPAND_YN([$1])])
  m4_append_uniq([_KCONF_VARS],[$1],[ ])
  AC_ARG_ENABLE(_var_,
		[AS_HELP_STRING(--enable-[]m4_translit(_var_,[_],[-]),[$2])],
		[AS_VAR_SET([$1],${enable_[]_var_})])
  m4_popdef([_var_])
  AC_POP_LOCAL([KCONFIG])
])



# AX_KCONFIG_CHOICE(VERBATIM_VAL, ENABLE_VAL1, VAL1, ENABLE_VAL2, VAL2, ...)
# ------------------------------------------------------------------------
AC_DEFUN([AX_KCONFIG_CHOICE],[
  AX_KCONFIG_CONDITIONAL([$2])
  AS_VAR_IF([$2],[yes], AS_VAR_SET([$1],[$3]))
  m4_if($#,0, ,m4_eval($# > 3),[1],[AX_KCONFIG_CHOICE($1,m4_shift3($@))], )
])

# AX_KCONFIG_WITH_CHOICE(VERBATIM_VAL, HELP_STRING,
#                        ENABLE_VAL1, VAL1, ENABLE_VAL2, VAL2, ...)
# ------------------------------------------------------------------------
AC_DEFUN([AX_KCONFIG_WITH_CHOICE],[
  AX_KCONFIG_VAR_WITH([$1],[$2])
  AX_KCONFIG_CHOICE($1,m4_shift2($@))
])






dnl No more needed .. local definition of ac_arg_enable
dnl -------
dnl AC_DEFUN_LOCAL([KCONFIG],[AC_ARG_ENABLE],
dnl [AC_PROVIDE_IFELSE([AC_PRESERVE_HELP_ORDER],
dnl [],
dnl [m4_divert_once([HELP_ENABLE], [[
dnl Optional Features:
dnl  --disable-option-checking  ignore unrecognized --enable/--with options
dnl  --disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
dnl  --enable-FEATURE[=ARG]  include FEATURE [ARG=yes]]])])dnl
dnl m4_divert_once([HELP_ENABLE], [$2])
dnl m4_pushdef([_tl_],m4_translit([$1],[-],[_]))
dnl m4_append_uniq([_AC_USER_OPTS], _tl_,[
dnl ])
dnl AS_IF([test "${[]_tl_+set}" = set], [_tl_val=_tl_; $3], [$4])
dnl m4_popdef([_tl_])
dnl ])# AC_ARG_ENABLE










