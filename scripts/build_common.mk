MAKE_PROCESS  ?= $(shell grep -c ^processor /proc/cpuinfo)
DOWNLOAD_DIR  ?= $(top_builddir)/download


## ////////////////////////////////////////////////////////////////////////// ##
## ///  DOWNLOAD  /////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

_flt ?= $(subst ' ',_,$(subst .,_,$1))

define dl__download_tar =
 $(info "Downloading tar file: $1")
 mkdir -p ${DOWNLOAD_DIR} $2; \
 _tar=${DOWNLOAD_DIR}/$$(echo $1 | sed -e 's|.*/||'); \
 test -f $$_tar || curl -SL $1 > $$_tar; \
 _wcl=$$(tar -tf $$_tar | sed -e 's|/.*||' | uniq | wc -l); \
 if test $$_wcl = 1; then \
  tar -xf $$_tar -C $2 --strip 1; \
 else \
  tar -xf $$_tar -C $2; \
 fi
endef

define dl__download_git =
 $(info "Downloading git repo: $1")
 git clone $1 $2 $(if $(value $(call _flt,$2)_BRANCH),-b $(value $(call _flt,$2)_BRANCH))
endef

define dl__download_generic =
 $(info "Downloading file: $1")
 mkdir -p ${DOWNLOAD_DIR}; \
 _f=${DOWNLOAD_DIR}/$$(echo $1 | sed -e 's|.*/||'); \
 test -f $$_f || curl -SL $1 > $$_f; \
 $(LN_S) $$_f $2;
endef

dl__tar_ext = %.tar %.tar.gz %.tar.xz %.tar.bz %.tar.bz2
dl__git_ext = %.git

$(DOWNLOADS):
	@ $(foreach x,$($(call _flt,$@)_URL),\
		$(info Download: $x) \
		$(if $(filter $(dl__tar_ext),$x),$(call dl__download_tar,$x,$@), \
		$(if $(filter $(dl__git_ext),$x),$(call dl__download_git,$x,$@), \
		$(call dl__download_generic,$x,$@) ) ) \
	   )


