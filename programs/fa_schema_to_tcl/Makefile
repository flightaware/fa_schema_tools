#
# fa_schma_tools Makefile for tcllauncher program fa_schema_to_tcl
#

LIB=/usr/local/lib
BIN=/usr/local/bin
TCLSH=tclsh8.5

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
