

# intermediate LEX + HASH file
zconf.tab.o: zconf.tab.c zconf.hash.c zconf.lex.c

# CONF
bin_PROGRAMS  = conf
conf_SOURCES  = conf.c
conf_LDADD    = zconf.tab.o

# NCONF
if HAVE_NCONF
 bin_PROGRAMS += nconf
 nconf_SOURCES = nconf.c nconf.gui.c
 nconf_LDADD = zconf.tab.o @MENU_LIB@ @PANEL_LIB@ @CURSES_LIB@
 nconf_CPPFLAGS = @CURSES_CPPFLAGS@
endif


MOSTLYCLEANFILES = zconf.tab.c zconf.hash.c zconf.lex.c \
                   zconf.tab.o




src = $(srcdir)
obj = $(builddir)
cmd = @$(cmd_$(1))


# Shipped files
# ===========================================================================

SUFFIXES = c_shipped h_shipped

quiet_cmd_shipped = SHIPPED $@
cmd_shipped = cat $< > $@

.c_shipped.c:
	$(call cmd,shipped)

.h_shipped.h:
	$(call cmd,shipped)


# GPERF
# ---------------------------------------------------------------------------
quiet_cmd_gperf = GPERF $@
      cmd_gperf = gperf -t --output-file $@ -a -C -E -g -k 1,3,$$ -p -t $<

.PRECIOUS: %.hash.c_shipped
%.hash.c_shipped: %.gperf
	$(call cmd,gperf)

# LEX
# ---------------------------------------------------------------------------
LEX_PREFIX = $(if $(LEX_PREFIX_${baseprereq}),$(LEX_PREFIX_${baseprereq}),yy)

quiet_cmd_flex = LEX     $@
      cmd_flex = flex -o$@ -L -P $(LEX_PREFIX) $<

.PRECIOUS: %.lex.c_shipped
%.lex.c_shipped: %.l
	$(call cmd,flex)

# YACC
# ---------------------------------------------------------------------------
YACC_PREFIX = $(if $(YACC_PREFIX_${baseprereq}),$(YACC_PREFIX_${baseprereq}),yy)

quiet_cmd_bison = YACC    $@
      cmd_bison = bison -o$@ -t -l -p $(YACC_PREFIX) $<

.PRECIOUS: %.tab.c_shipped
%.tab.c_shipped: %.y
	$(call cmd,bison)

quiet_cmd_bison_h = YACC    $@
      cmd_bison_h = bison -o/dev/null --defines=$@ -t -l -p $(YACC_PREFIX) $<

.PRECIOUS: %.tab.h_shipped
%.tab.h_shipped: %.y
	$(call cmd,bison_h)

