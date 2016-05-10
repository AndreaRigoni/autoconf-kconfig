
# CONF
bin_PROGRAMS  = conf
conf_SOURCES  = conf.c zconf.tab.c

# NCONF
if ENABLE_NCONF
 bin_PROGRAMS += nconf
 nconf_SOURCES = nconf.c nconf.gui.c zconf.tab.c
 nconf_LDADD = @MENU_LIB@ @PANEL_LIB@ @CURSES_LIB@
 nconf_CPPFLAGS = @CURSES_CPPFLAGS@
endif
