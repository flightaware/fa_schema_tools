#
# FLightAware fa_schema_tools Makefile
#
# "make" to generate the pkgIndex.tcl file
#
# "make install" to copy all the stuff into a dir where Tcl can find it
#

INSTALLBASE=/usr/local/lib
INSTALLDIR=$(INSTALLBASE)/fa_schema_tools
TCLSH=tclsh8.5

all:
	echo "pkg_mkIndex -direct -verbose . *.tcl"  | $(TCLSH)

install:	all
	mkdir -p $(INSTALLDIR)
	cp -R *.tcl $(INSTALLDIR)
