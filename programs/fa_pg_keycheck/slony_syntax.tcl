#
# flightaware slony prep stuff - generate partial slony config
#
# $Id: slony_syntax.tcl,v 1.1 2009-02-15 06:44:45 karl Exp $
#

package require Tclx; # for lassign

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

