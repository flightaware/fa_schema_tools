#
# fa_schma_tools Makefile for tclluancher program fa_pg_log_groper
#

LIB=/usr/local/lib
BIN=/usr/local/bin
TCLSH=tclsh8.5

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
