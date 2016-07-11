FlightAware Schema Tools
---

*FlightAware Schema Tools* consists of a package and programs to pull schema definitions out of PostgreSQL and interpret them in various ways.

The most important is probably the ability to obtain and then compare the definition of two Postgres database schemas, reporting every table that is in one but not the other and reporting the differences in the definition of each table, for any tables where differences exist, and producing ALTER TABLE, CREATE INDEX, and DROP INDEX commands to make the second database schema match the first.

fa_schema_tools requires Tcl 8.5 or newer be installed and requires that the TclX extension and the tcllauncher extension be installed as well (https://github.com/flightaware/tcllauncher)

fa_pg_schema_to_tcl
---

**fa_pg_schema_to_tcl** connects to a PostgreSQL database, reads the database definition from various tables, and produces Tcl code that can be executed to render that database's schema definition into Tcl data structures for further interpretation, groping, etc.

Example usage:
```sh
 fa_pg_schema_to_tcl dbname DATABASENAME host HOST1 user USER password PASSWORD >/tmp/schema1

 fa_pg_schema_to_tcl dbname DATABASENAME host HOST2 user USER password PASSWORD >/tmp/schema2
```

fa_pg_schema_compare
---

**fa_pg_schema_compare** compares the definition of two database schemas produced by **fa_pg_schema_to_tcl**, reporting every table that is in one but not the other and reporting the differences in the definition of each table, if differences exist, and producing *ALTER TABLE* commands to make the second database schema match the first.


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

**fa_pg_keycheck** is a Tcl program that qualify a PostgreSQL database for use with replication via the **Slony** replication system (http://slony.info/).  fa_pg_keycheck gropes through a database, looking at the metadata information for each the tables to see if there's a primary key for the table and, if not, to see if there's a unique key that's comprised of one or more fields, all of which are non-null.

All tables matching one of those criteria can be fed straight to slony.

Tables that don't have a primary key or non-null unique key need to have one added before they can be used with Slony.  For any tables it finds that do not fit the criteria, fa_pg_keycheck will emit the DDL necessary to create a unique key and index. For instance for a table named *monkey* that has no qualifying index, it will emit

```sql
-- monkey create new column 'id'
begin;
  create sequence monkey_id_seq;
  alter table monkey add column id integer;
  update monkey set id = nextval('monkey_id_seq');
  alter table monkey alter column id set not null;
  create unique index monkey_id_key on monkey (id);
end;
```

Finally, fa_pg_keycheck will emit configuration data for all the database tables that can be pasted into slony, including tables that have a primary key, tables that do not have a primary key but have a unique key along with the qualifying key name, and a list of all the sequences to be replicated.

Carefully inspect the output before running anything.  We recommend using a test database before trying it on your production one.  You'll also probably need to issue some GRANTs on the new keys and sequences to appropriate users and/or roles.


fa_pg_log_groper
---

fa_pg_log_groper will follow a syslog file that PostgreSQL is logging to and reaseemble the multi-line logging format into single lines.  Handy for seeing what's going on because log messages will often span many log lines.


How To Dump Just The Schema
---

As user pgsql or something,

pg_dumpall --schema-only asdidata >asdidata.sql

