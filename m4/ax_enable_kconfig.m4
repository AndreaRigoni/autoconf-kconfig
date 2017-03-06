# AX_GETVAR_SUBDIR
# -----------------
# subdir, var, [subvar] (if different from var)
AC_DEFUN([AX_GETVAR_SUBDIR],[
  m4_pushdef([subvar],[m4_default($3,$2)])
  AS_VAR_SET([$2],$(echo '@subvar@' | $1/config.status --file=-))
  m4_popdef([subvar])
])


AC_DEFUN([AX_KCONFIG_EXPAND_YN],[
  AS_CASE([$(eval echo \$$1)],
	  [y],AS_VAR_SET([$1],[yes]),
	  [n],AS_VAR_SET([$1],[no]))
])

AC_DEFUN([AX_KCONFIG_COMPRESS_YN],[
  AS_CASE([$(eval echo \$$1)],
	  [yes],AS_VAR_SET([$1],[y]),
	  [no],AS_VAR_SET([$1],[n]))
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

  # Add kconf variables to DEFAULTS diversion
  m4_wrap_lifo([m4_divert_text([DEFAULTS],
  [ax_kconfig_user_vars='
  m4_ifdef([_AX_KCONF_VARS], [m4_defn([_AX_KCONF_VARS])
  ])'
  ])])
  # Add kconf options to DEFAULTS diversion
  m4_wrap_lifo([m4_divert_text([DEFAULTS],
  [ax_kconfig_user_opts='
  m4_ifdef([_AX_KCONF_OPTS], [m4_defn([_AX_KCONF_OPTS])
  ])'
  ])])

  # preparse option variables
  for opt in $ax_kconfig_user_opts; do
    var=${opt#*:}
    opt=${opt%:*}
    #echo $opt;
    AS_CASE([$opt],
     # enable
     [enable_*],
     [AS_VAR_SET_IF([$(eval echo $opt)],[
      AS_VAR_SET([$var],[$(eval echo \$$opt)])
      AS_VAR_SET([CONFIG_$var], $(eval echo \$$opt))
      AX_KCONFIG_COMPRESS_YN([CONFIG_$var])
      export CONFIG_$var
     ])],
     # with
     [with_*],
     [AS_VAR_SET_IF([$(eval echo $opt)],[
      AS_VAR_SET([$var],[$(eval echo \$$opt)])
      AS_VAR_SET([CONFIG_$var], $(eval echo \$$opt))
      AX_KCONFIG_COMPRESS_YN([CONFIG_$var])
      export CONFIG_$var
     ])],
     # default
     [])
  done;

  AC_ARG_ENABLE([kconfig],
    [AS_HELP_STRING([--enable-kconfig=flavor],
      [Enable fancy configure with flavor in (conf | nconf) [[default=nconf]]])
    ],
    [AS_VAR_IF([enableval],[yes],
	       [AS_VAR_SET([enable_kconfig],[nconf])],
	       [AS_VAR_SET([enable_kconfig],[$enableval])])],
    [AS_VAR_SET_IF([ENABLE_KCONFIG],
		   [AS_VAR_SET([enable_kconfig],[${ENABLE_KCONFIG}])],
		   [AS_VAR_SET([enable_kconfig],[update])]
dnl		   [AS_IF([test -f .config],,AS_VAR_SET([enable_kconfig],[update]))]
dnl		   [AS_VAR_SET([enable_kconfig],[no])]
		   )]
  )

  dnl this is needed by dockerbuild to disable kconfig (fix it)
  AS_VAR_SET_IF([ENABLE_KCONFIG],
		[AS_VAR_SET([enable_kconfig],[${ENABLE_KCONFIG}])],
		[])

  ## interactive console only
  AS_IF([test -t AS_ORIGINAL_STDIN_FD -o -p /dev/stdin],[
   AS_ECHO(["interactive console"])
   AS_CASE([${enable_kconfig}],
	  # conf
	  [conf],
	  [$SHELL -c "srctree=${srcdir} ${KCONFIG_CONF} Kconfig" <&AS_ORIGINAL_STDIN_FD],

	  # nconf
	  [nconf],
	  [$SHELL -c "srctree=${srcdir} ${KCONFIG_NCONF} Kconfig" <&AS_ORIGINAL_STDIN_FD],

	  )])

  ## for non interactive console also
  AS_CASE([${enable_kconfig}],
	   # create default .config
	   [default],
	   [$SHELL -c "srctree=${srcdir} ${KCONFIG_CONF} --alldefconfig Kconfig"],
	   # update
	   [update],
	   [AC_CONFIG_COMMANDS([kconfig-update],
		     [AX_GETVAR_SUBDIR([$1],[KCONFIG_CONF])
		      AS_ECHO(["store back configuration to .config"])
		      $SHELL -c "srctree=${srcdir} ${KCONFIG_CONF} --updateconfig Kconfig"
		      ## $SHELL -c "srctree=${srcdir} ${KCONFIG_CONF}
		      ##        --savedefconfig .defconfig Kconfig"
		      ],[])]
	  )

  # ---- APPLY KCONFIG CONFIG ---- #
  [ test -f .config ] && source ./.config
  AS_VAR_SET([subdirs],[$subdirs_SAVE])
])



# AX_KCONFIG_VAR(VAR)
# ------------------------------------------------------------------------
AC_DEFUN([AX_KCONFIG_VAR],[
  m4_pushdef([_var_],[$1])
  AS_VAR_SET_IF(_var_,,[AS_VAR_SET_IF([CONFIG_]_var_[],
			       [AS_VAR_SET(_var_,${[CONFIG_]_var_[]})])])

  AS_VAR_SET_IF(_var_,[AS_VAR_SET([CONFIG_]_var_[],${_var_})]
		      [export [CONFIG_]_var_])

  m4_append_uniq([_AX_KCONF_VARS],[$1],[
  ])

  dnl  AC_SUBST(_var_)
  m4_popdef([_var_])
])

# AX_KCONFIG_CONDITIONAL(VAR)
# ------------------------------------------------------------------------
AC_DEFUN([AX_KCONFIG_CONDITIONAL],[
  m4_pushdef([_var_],[$1])
  AS_VAR_SET_IF(_var_,,[AS_VAR_SET_IF([CONFIG_]_var_,
			       [AS_VAR_SET(_var_,${[CONFIG_]_var_[]})]
			       [AX_KCONFIG_EXPAND_YN(_var_)])])

  AS_VAR_SET_IF(_var_,[AS_VAR_SET([CONFIG_]_var_[],${_var_})]
		      [AX_KCONFIG_COMPRESS_YN([CONFIG_]_var_)]
		      [export [CONFIG_]_var_])

  m4_append_uniq([_AX_KCONF_VARS],[$1],[
  ])

  AM_CONDITIONAL(_var_, test x"${_var_}" = x"yes")
  dnl  AC_SUBST(_var_)
  m4_popdef([_var_])
])


# AX_KCONFIG_VAR_WITH(FEATURE, HELP, [ACTION-IF-TRUE], [ACTION-IF-FALSE])
# ------------------------------------------------------------------------
AC_DEFUN([AX_KCONFIG_VAR_WITH],[
  m4_pushdef([_var_],m4_bpatsubst(m4_tolower(m4_translit([$1],[_-],[__])),[^with_],[]))
  #AS_VAR_SET_IF([$1],,[AS_VAR_SET([$1],${[CONFIG_$1]})]
		      #[AX_KCONFIG_EXPAND_YN([$1])])
  AS_VAR_SET_IF([$1],,[AS_VAR_SET_IF([CONFIG_$1],
				     [AS_VAR_SET([$1],${[CONFIG_$1]})]
				     [AX_KCONFIG_EXPAND_YN([$1])])])

  AC_ARG_WITH(_var_,
	      [AS_HELP_STRING(--with-[]m4_translit(_var_,[_],[-]),[$2])],
	      [AS_VAR_SET([$1],${with_[]_var_})])

  m4_append_uniq([_AX_KCONF_VARS],[$1],[
  ])
  m4_append_uniq([_AX_KCONF_OPTS],with_[]_var_:[$1],[
  ])

  AS_VAR_SET_IF([$1],[AS_VAR_SET([CONFIG_$1],${[$1]})]
		     [AX_KCONFIG_COMPRESS_YN([CONFIG_$1])]
		     [export CONFIG_$1])

  m4_popdef([_var_])
])


# AX_KCONFIG_VAR_ENABLE(FEATURE, HELP, [ACTION-IF-TRUE], [ACTION-IF-FALSE])
# ------------------------------------------------------------------------
AC_DEFUN([AX_KCONFIG_VAR_ENABLE],[
  m4_pushdef([_var_],m4_bpatsubst(m4_tolower(m4_translit([$1],[_-],[__])),[^enable_],[]))
  #AS_VAR_SET_IF([$1],,[AS_VAR_SET([$1],${[CONFIG_$1]})]
		      #[AX_KCONFIG_EXPAND_YN([$1])])
  AS_VAR_SET_IF([$1],,[AS_VAR_SET_IF([CONFIG_$1],
				     [AS_VAR_SET([$1],${[CONFIG_$1]})]
				     [AX_KCONFIG_EXPAND_YN([$1])])])

  AC_ARG_ENABLE(_var_,
		[AS_HELP_STRING(--enable-[]m4_translit(_var_,[_],[-]),[$2])],
		[AS_VAR_SET([$1],${enable_[]_var_})])

  m4_append_uniq([_AX_KCONF_VARS],[$1],[
  ])
  m4_append_uniq([_AX_KCONF_OPTS],enable_[]_var_:[$1],[
  ])

  AS_VAR_SET_IF([$1],[AS_VAR_SET([CONFIG_$1],${[$1]})]
		     [AX_KCONFIG_COMPRESS_YN([CONFIG_$1])]
		     [export CONFIG_$1])

  m4_popdef([_var_])
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










