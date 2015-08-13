#
# fa_schema_tools Makefile for tcllauncher program fa_pg_schema_compare
#

LIB=/usr/local/lib
BIN=/usr/local/bin
TCLSH=tclsh

SERVER_INSTALLFILES= main.tcl

PROGNAME=fa_pg_schema_compare

all:
	@echo "'make install' to install $(PROGNAME)"

install-program:
	@echo ---- installing program
	-install $(BIN)/tcllauncher $(BIN)/$(PROGNAME)
	mkdir -p $(LIB)/$(PROGNAME)
	cp $(SERVER_INSTALLFILES) $(LIB)/$(PROGNAME)

install: install-program
