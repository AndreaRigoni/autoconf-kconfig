## include project files
include $(addprefix $(srcdir)/,$(PRO))

QMAKE_BUILD_FLAVOR ?=
QMAKE_CONFIG ?=

CLEANFILES ?= $(TARGET)

list: ##@qt list all available qt targets
	@ $(info |         ) \
	  $(info | TARGETS:) \
	  $(foreach x,$(TARGET),$(info |          $x)) \
	  $(info |         )

Makefile.qt: $(PRO) $(FORMS)
	@ $(QMAKE_BINARY) $(foreach x,$(QMAKE_CONFIG),CONFIG+=$x ) -o $@ $<

qmake_: ##@qt build target in qt build (Makefile.qt)
qmake_%: Makefile.qt
	@ $(MAKE) -f $< $(subst qmake_,,$@)

$(TARGET): Makefile.qt $(SOURCES) $(HEADERS)
	@ $(info | ) \
	  $(info | Performing qt flavor: $(QMAKE_BUILD_FLAVOR)) \
	  $(info | ) \
	  $(MAKE) -f $< $@

clean-local: qmake_clean
	@ rm -rf $(CLEANFILES)

