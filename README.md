FlightAware Schema Tools
---

Package and programs to pull schema definitions out of PostgreSQL and interpret them in various ways.

The most important is probably the ability to obtain and then compare the definition of two Postgres database schemas, reporting every table that is in one but not the other and reporting the differences in the definition of each table, if differences exist, and producing ALTER TABLE, CREATE INDEX, and DROP INDEX commands to make the second database schema match the first.

fa_schema_tools requires Tcl 8.5 or newer be installed and requires that the TclX extension and the tcllauncher extension be installed as well (https://github.com/flightaware/tcllauncher)

fa_pg_schema_to_tcl
---

fa_pg_schema_to_tcl connects to a PostgreSQL database, reads the database definition from various tables, and produces Tcl code that can be executed to render that database's schema definition into Tcl data structures for further interpretation, groping, etc.

Example usage:
```sh
 fa_pg_schema_to_tcl dbname DATABASENAME host HOST1 user USER password PASSWORD >/tmp/schema1

 fa_pg_schema_to_tcl dbname DATABASENAME host HOST2 user USER password PASSWORD >/tmp/schema2
```

fa_pg_schema_compare
---

fa_pg_schema_compare compares the definition of two database schemas produced by fa_pg_schema_to_tcl, reporting every table that is in one but not the other and reporting the differences in the definition of each table, if differences exist, and producing ALTER TABLE commands to make the second database schema match the first.


```sh
 fa_pg_schema_compare /tmp/schema1 /tmp/schema2
```

```
 -- tables defined in second schema only:
 --     accounts_myspace

 -- Added package_delivery index "package_delivery_date"
 CREATE INDEX package_delivery_date ON package_delivery USING btree (date);

 -- Added package_geo fields "continent sub_continent"
 ALTER TABLE package_geo ADD COLUMN continent character varying;
 ALTER TABLE package_geo ADD COLUMN sub_continent character varying;
```

fa_pg_keycheck
---

fa_pg_keycheck is a Tcl program that will grope through a PostgreSQL database, looking at each the tables in the database to see if there's a primary key for the table and, if not, to see if there's a unique key that's comprised of one or more fields, all of which are non-null.

All of those tables can be fed straight to slony.

Tables that don't have a primary key or non-null unique key need to have one added.

fa_pg_log_groper
---

fa_pg_log_groper will follow a syslog file that postgresql is logging to and reaseemble the multi-line logging format into single lines.  Handy for seeing what's going on.


How To Dump Just The Schema
---

As user pgsql or something,

pg_dumpall --schema-only asdidata >asdidata.sql

