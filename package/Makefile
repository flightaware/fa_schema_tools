#
# "make" to generate the pkgIndex.tcl file
#
# "make install" to copy all the stuff into a dir where Tcl can find it
#
# $Id: Makefile,v 1.1 2009-02-14 15:55:29 karl Exp $
#

TARGETDIR=/usr/local/lib/fa_schema_tools

all:
	echo "pkg_mkIndex -direct -verbose . *.tcl"  | tclsh8.4

install:	all
	mkdir -p $(TARGETDIR)
	cp -R *.tcl $(TARGETDIR)
