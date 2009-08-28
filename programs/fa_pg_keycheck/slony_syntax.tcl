#
# flightaware slony prep stuff - generate partial slony config
#

package require Tclx; # for lassign

#
# gen_slony_pkey_ukey - generate the slony config tables for tables with
#  a primary key and tables with a unique, nonnull key
#
proc gen_slony_pkey_ukey {pkeyTables ukeyTables} {
    set string "    \"pkeyedtables\" => \[\n"

    foreach table $pkeyTables {
        append string "        '$table',\n"
    }

    append string "                        \],\n"
    append string "\n"

    append string "    \"keyedtables\" => \173\n"
    foreach pair $ukeyTables {
	lassign $pair table key
	append string "        '$table' => '$key',\n"
    }
    append string "    \175,"

    return $string
}

#
# gen_slony_sequences - generate the slony config file format for all
#  of the sequences
#
proc gen_slony_sequences {sequences} {
    set string "    \"sequences\" => \[\n"

    foreach sequence $sequences {
        append string "        '$sequence',\n"
    }

    append string "         \],\n"
    append string "\n"

    return $string
}

