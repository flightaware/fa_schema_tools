

$Id: README.txt,v 1.1 2009-02-14 16:59:26 karl Exp $

Index Check is a Tcl program that will grope through a PostgreSQL database,
looking at each the tables in the database to see if there's a primary
key for the table and, if not, to see if there's a unique key that's
comprised of one or more fields, all of which are non-null.

All of those tables can be fed straight to slony.

Tables that don't have a primary key or non-null unique key need to have
one added.  See the NOTES.txt for details.


