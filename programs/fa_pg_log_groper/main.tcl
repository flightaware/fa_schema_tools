#
#
#
#
#
#

package require Tclx
#catch {parray foo}
#cmdtrace on

#Feb 16 00:29:44 zulu postgres[44626]: [21-20]check_barr_override(b.ident,b.filed_departuretime,b.blocked) as blocked,

proc crack_line {line arrayName} {
    upvar $arrayName array

    set pattern {^(...............) ([^ ]*) ([^[]*)\[([^\]]*)]: (.*)}
    puts [regexp $pattern $line dummy array(date) array(host) array(program) array(pid) array(body)]
    #\[([^-]*)-([^\]]*)](.*)
    parray array
    puts ""
}

proc run {} {
    set fp [open /var/log/postgres.log]

    while {[gets $fp line] >= 0} {
	puts $line
	crack_line $line array
    }

    close $fp
}

proc doit {{argv ""}} {
    run
}

if !$tcl_interactive {
    doit $argv
}
