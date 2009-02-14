#
# fa_schma_tools Makefile for tclluancher program fa_schema_to_tcl
#
# $Id: Makefile,v 1.1 2009-02-14 16:07:52 karl Exp $
#

LIB=/usr/local/lib
BIN=/usr/local/bin
TCLSH=tclsh8.4

SERVER_INSTALLFILES= main.tcl

PROGNAME=fa_schema_to_tcl

all:
	@echo "'make install' to install $(PROGNAME)"

install-program:
	@echo ---- installing program
	-install $(BIN)/tcllauncher $(BIN)/$(PROGNAME)
	mkdir -p $(LIB)/$(PROGNAME)
	cp $(SERVER_INSTALLFILES) $(LIB)/$(PROGNAME)

install: install-program
