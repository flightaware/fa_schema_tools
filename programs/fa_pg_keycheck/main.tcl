#
# flightaware program to look at a postgresql database, show all tables that
# have a primary key, show all tables that have a unique index  where all
# components of the index are not null, and all tables that do not have
# a unique, nonnull index.
#
# $Id: main.tcl,v 1.3 2009-02-14 17:21:44 karl Exp $
#
namespace eval ::db {source asdidata.tcl}

source genindex.tcl

set pkeyTables [list]
set ukeyTables [list]

#
# unique_check - given a table and an index name, see if the index is comprised
#  only of fields that are marked not null
#
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
	    puts "-- field $indexedField allows NULL, CAN'T USE IT"
	    puts ""
	    return
	}
	#parray field
	#puts ""
    }

    puts "-- ACCEPTED key $element for table $table"
    puts ""
}

#
# default_sequence_check - see if table contains a field that has a default
#  derived from a sequence.  if so, return that field name, if not, return
#  an empty string.
#
proc default_sequence_check {table} {
    upvar ::db::${table}::indices indices
    upvar ::db::${table}::fields fields

    foreach fieldName $fields {
	upvar ::db::${table}::fields::${fieldName} field
	if {[string first "nextval" $field(default)] >= 0} {
	    return $fieldName
	}
    }

    return ""
}

#
# do_table - given a table, look to see if the table has a primary key or,
#  if not, if it has a unique non-null key, recording that in either case.
#
#  if it has neither, emit SQL to add one
#
proc do_table {table} {
    global pkeyTables ukeyTables

    upvar ::db::${table}::indices indices
    upvar ::db::${table}::fields fields

    foreach element $indices {
	upvar ::db::${table}::indices::${element} index
	if {$index(indisprimary)} {
	    puts "-- $table PRIMARY KEY $element"
	    lappend pkeyTables $table
	    return
	} elseif {$index(indisunique)} {
	    puts "-- $table UNIQUE KEY $element"
	    lappend ukeyTables [list $table $element]
	    unique_check $table $element
	    #parray index
	    return
	} else {
	    continue
	}
    }

    set candidate [default_sequence_check $table]
    if {$candidate != ""} {
	puts "-- $table's $candidate field needs an index!"
	puts "create unique index [gen_index_name $table $candidate] on $table ($candidate);"
	return
    }

    puts "-- $table NO USABLE KEY"
    set newColumnName [gen_column_name $fields]
    puts "-- new column name: $newColumnName"

    set newIndexName [gen_index_name $table $newColumnName]
    puts "-- new index name: $newIndexName"

    set newSequenceName [gen_sequence_name $table $newColumnName]
    puts "-- new sequence name: $newSequenceName"

    puts [gen_index $table $newSequenceName $newColumnName $newIndexName ]
    puts ""
    lappend ukeyTables [list $table $newColumnName]

}

proc run {} {
    global tables

    puts "-- MACHINE GENERATED ON [clock format [clock seconds]] DO NOT EDIT"
    puts "--"
    puts "--"

    foreach table $::db::tables {
	do_table $table
	puts ""
    }
}

run

