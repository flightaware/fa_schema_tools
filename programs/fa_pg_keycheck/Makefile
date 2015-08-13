#
# fa_schma_tools Makefile for tcllauncher program fa_schema_to_tcl
#

LIB=/usr/local/lib
BIN=/usr/local/bin
TCLSH=tclsh

SERVER_INSTALLFILES= main.tcl genindex.tcl slony_syntax.tcl

PROGNAME=fa_pg_keycheck

all:
	@echo "'make install' to install $(PROGNAME)"

install-program:
	@echo ---- installing program
	-install $(BIN)/tcllauncher $(BIN)/$(PROGNAME)
	mkdir -p $(LIB)/$(PROGNAME)
	cp $(SERVER_INSTALLFILES) $(LIB)/$(PROGNAME)

install: install-program
