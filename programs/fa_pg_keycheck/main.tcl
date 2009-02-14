#
# flightaware program to look at a postgresql database, show all tables that
# have a primary key, show all tables that have a unique index  where all
# components of the index are not null, and all tables that do not have
# a unique, nonnull index.
#
# $Id: main.tcl,v 1.1 2009-02-14 09:04:39 karl Exp $
#
namespace eval ::db {source asdidata.tcl}

proc unique_check {table element} {
    upvar ::db::${table}::indices indices
    upvar ::db::${table}::fields fields

    upvar ::db::${table}::indices::${element} index

    set createIndexStatement $index(pg_get_indexdef)
    regexp {\(([^)]*)} $createIndexStatement dummy indexedFields

    foreach indexedField [split $indexedFields ","] {
	set indexedField [string trim $indexedField]

	upvar ::db::${table}::fields::${indexedField} field
	#puts "Unique Check Field $indexedField"
	if {!$field(attnotnull)} {
	    puts "field $indexedField allows NULL, CAN'T USE IT"
	    puts ""
	    return
	}
	#parray field
	#puts ""
    }

    puts "ACCEPTED key $element for table $table"
    puts ""
}

proc do_table {table} {
    upvar ::db::${table}::indices indices
    upvar ::db::${table}::fields fields

    foreach element $indices {
	upvar ::db::${table}::indices::${element} index
	if {$index(indisprimary)} {
	    puts "$table PRIMARY KEY $element"
	    return
	} elseif {$index(indisunique)} {
	    puts "$table UNIQUE KEY $element"
	    unique_check $table $element
	    #parray index
	    return
	} else {
	    continue
	}
    }

    puts "$table NO USABLE KEY"

if 0 {
    foreach element $fields {
	puts "    FIELD $element"
	upvar ::db::${table}::fields::${element} fields
	parray fields
	puts ""
    }
}

}


proc run {} {
    global tables

    foreach table $::db::tables {
	do_table $table
	puts ""
    }
}

run

