#
# fa_schma_tools Makefile for tclluancher program fa_pg_log_groper
#
# $Id: Makefile,v 1.1 2009-02-16 08:12:36 karl Exp $
#

LIB=/usr/local/lib
BIN=/usr/local/bin
TCLSH=tclsh8.4

SERVER_INSTALLFILES= main.tcl

PROGNAME=fa_pg_log_groper

all:
	@echo "'make install' to install $(PROGNAME)"

install-program:
	@echo ---- installing program
	-install $(BIN)/tcllauncher $(BIN)/$(PROGNAME)
	mkdir -p $(LIB)/$(PROGNAME)
	cp $(SERVER_INSTALLFILES) $(LIB)/$(PROGNAME)

install: install-program
