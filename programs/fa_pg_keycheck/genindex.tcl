#
# gen_index - routine to create SQL to alter a table to add and populate
#  a unique, nonnull index for a table
#
# $Id: genindex.tcl,v 1.1 2009-02-14 16:59:26 karl Exp $
#

#
# gen_index - given a table name, new sequence name, new column name, and
#  a new name for the new column's new index, return SQL code to
#   * create the sequence
#   * add the new column to the table
#   * populate 
#
proc gen_index {tableName newSequenceName newColumnName newIndexName} {
    set string "begin;\n"
    append string "  create sequence $newSequenceName;\n"
    append string "  alter table $tableName add column $newColumnName integer;\n"
    append string "  update $tableName set $newColumnName = nextval('$newSequenceName');\n"
    append string "  alter table $tableName alter column $newColumnName set not null;\n"
    append string "  create unique index $newIndexName on $tableName ($newColumnName);\n"
    append string "end;"

    return $string
}

#
# gen_column_name - given a list of fields, generate a name for an index column
#  that isn't already in the list of fields
#
proc gen_column_name {fields} {
    set possibleColumnNames "id seq serial idnum idnumber serialnumber sequence_number idseq seqid axolotl noway i dont believe it"

    foreach columnName $possibleColumnNames {
	if {[lsearch $fields $columnName] < 0} {
	    return $columnName
	}
    }

    error "you've gotta be kidding me - all of the possible column names ($possibleColumnNames) i could come up with already exist in the table"
}

#
# gen_index_name - given a table name and column name, return an index name
#
proc gen_index_name {table column} {
    return "${table}_${column}_key"
}

#
# gen_sequence_name - given a table name and column name, return a
#  decent sequence name
#
proc gen_sequence_name {table column} {
    return "${table}_${column}_seq"
}
