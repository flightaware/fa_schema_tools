#
#
#
#
#
#

package require Tclx
#catch {parray foo}
#cmdtrace on


set logPattern {^(...............) ([^ ]*) ([^[]*)\[([^\]]*)]: (.*)}

set postgresPattern {\[([^-]*)-([^\]]*)] *(.*)}

#Feb 16 00:29:44 zulu postgres[44626]: [21-20]check_barr_override(b.ident,b.filed_departuretime,b.blocked) as blocked,

proc crack_line {line arrayName} {
    global logPattern postgresPattern
    upvar $arrayName array

    if {![regexp $logPattern $line dummy array(date) array(host) array(program) array(pid) array(body)]} {
	puts stderr "couldn't crack: $line"
	return
    }

    if {[regexp $postgresPattern $array(body) dummy array(pgMajorID) array(pgMinorID) array(pgFragment)]} {
	set array(pgFragment) [string trim $array(pgFragment)]
    }

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
