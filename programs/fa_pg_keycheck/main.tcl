#
# flightaware program to look at a postgresql database, show all tables that
# have a primary key, show all tables that have a unique index  where all
# components of the index are not null, and all tables that do not have
# a unique, nonnull index.
#

# tcllauncher launchdir check
if {[info exists ::launchdir]} {
    cd $::launchdir
}

source genindex.tcl
source slony_syntax.tcl

set pkeyTables [list]
set ukeyTables [list]

#
# unique_check - given a table and an index name, see if the index is comprised
#  only of fields that are marked not null
#
# returns 1 if the key can be used, 0 if it can't
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
	    #puts "-- $table field $indexedField allows null, can't use it"
	    #puts ""
	    return 0
	}
    }

    #puts "-- ACCEPTED key $element for table $table"
    #puts ""
    return 1
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
	    puts "-- $table OK (primary key '$element')"
	    lappend pkeyTables $table
	    return
	} elseif {$index(indisunique)} {
	    # if all component fields are not null, we can use this
	    # and we're done
	    if {[unique_check $table $element]} {
		puts "-- $table OK (unique key '$element')"
		lappend ukeyTables [list $table $element]
		return
	    }
	} else {
	    continue
	}
    }

    #
    # fell through -- we need to make an index
    #
    set candidate [default_sequence_check $table]
    if {$candidate != ""} {
	puts "-- $table, give field '$candidate' a unique index"
	puts "create unique index [gen_index_name $table $candidate] on $table ($candidate);"
	return
    }

    set newColumnName [gen_column_name $fields]
    #puts "-- $table new column $newColumnName"

    set newIndexName [gen_index_name $table $newColumnName]
    #puts "-- $table new index $newIndexName"

    set newSequenceName [gen_sequence_name $table $newColumnName]
    #puts "-- $table new sequence $newSequenceName"

    puts "-- $table create new column '$newColumnName'"

    puts [gen_index $table $newSequenceName $newColumnName $newIndexName ]
    puts ""
    lappend ukeyTables [list $table $newColumnName]
}

#
# run - generate the intrepretable results of all the table definitions
#
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

#
# doit - main program
#
proc doit {{argv ""}} {
    set tclCode [eval exec fa_schema_to_tcl $argv]
    namespace eval ::db $tclCode
    run

    puts [gen_slony_pkey_ukey $::pkeyTables $::ukeyTables]

    puts [gen_slony_sequences $::db::sequences]
}

if {!$tcl_interactive} {
    doit $argv
}

