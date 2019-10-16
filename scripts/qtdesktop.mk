## ////////////////////////////////////////////////////////////////////////// //
##
## This file is part of the autoconf-bootstrap project.
## Copyright 2018 Andrea Rigoni Garola <andrea.rigoni@igi.cnr.it>.
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.
##
## ////////////////////////////////////////////////////////////////////////// //



## include project files (not actually possible unfortunately)
## include $(or $(wildcard $(PRO)),\
##			 $(wildcard $(addprefix $(srcdir)/,$(PRO))))

QMAKE_BUILD_FLAVOR ?=
QMAKE_CONFIG ?=

CLEANFILES ?= $(TARGET)

export builddir \
	   top_builddir \
	   srcdir \
	   top_srcdir

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

$(TARGET): Makefile.qt $($(TARGET)_SOURCES) $($(TARGET)_HEADERS) $($(TARGET)_FORMS)
	@ $(info | ) \
	  $(info | Performing qt flavor: $(QMAKE_BUILD_FLAVOR)) \
	  $(info | ) \
	  $(MAKE) -f $< $@

# this is needed because of the use of variable HEADERS
override includedir = $(builddir)

clean-local: qmake_clean
	@ rm -rf $(CLEANFILES) Makefile.qt



# //////////////////////////////////////////////////////////////////////////// #
# //  EXAMPLE  /////////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #
#
# include $(top_srcdir)/Common.mk
# include $(abs_top_srcdir)/conf/kscripts/qtdesktop.mk
#
# PRO = myapp.pro
#
# all: $(TARGET)
# clean: clean-local
