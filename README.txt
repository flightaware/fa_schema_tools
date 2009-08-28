README
======

FlightAware Schema Tools

Package and programs to pull schema definitions out of PostgreSQL and
interpret them in various ways.

fa_pg_keycheck
--------------

fa_pg_keycheck is a Tcl program that will grope through a PostgreSQL database,
looking at each the tables in the database to see if there's a primary
key for the table and, if not, to see if there's a unique key that's
comprised of one or more fields, all of which are non-null.

All of those tables can be fed straight to slony.

Tables that don't have a primary key or non-null unique key need to have
one added.

fa_pg_log_groper
----------------

fa_pg_log_groper will follow a syslog file that postgresql is logging to and
reaseemble the multi-line logging format into single lines.  Handy for
seeing what's going on.

fa_schema_to_tcl
----------------

fa_schema_to_tcl connects to a PostgreSQL database, reads the database
definition from various tables, and produces Tcl code that can be executed
to render that data into Tcl data structures for further interpretation,
groping, etc.


How To Dump Just The Schema
---------------------------

As user pgsql or something,

pg_dumpall --schema-only asdidata >asdidata.sql

