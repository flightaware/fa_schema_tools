

all:
	@echo "'make install' to install fa_schema_tools package and programs"

install:
	cd package; make install
	cd programs; make install
