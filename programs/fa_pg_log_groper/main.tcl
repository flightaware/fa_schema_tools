#
#
#
#
# $Id: main.tcl,v 1.3 2009-02-16 08:02:04 karl Exp $
#

package require Tclx
#catch {parray foo}
#cmdtrace on

set sequence 0


set logPattern {^(...............) ([^ ]*) ([^[]*)\[([^\]]*)]: (.*)}

set postgresPattern {\[([^-]*)-([^\]]*)] *(.*)}

#Feb 16 00:29:44 zulu postgres[44626]: [21-20]check_barr_override(b.ident,b.filed_departuretime,b.blocked) as blocked,

#
# crack_line - crack a log line into an array
#
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

    #parray array
    #puts ""
}

#
# assemble - given an array from a cracked log line, assemble multiple lines
#  into coherent stuff
#
proc assemble {arrayName} {
    global collector sequences sequence
    upvar $arrayName array

    if {![info exists array(pgMajorID)]} {
	return
    }

    if {$array(pgMinorID) == 1} {
	incr sequence
    }

    set id $array(pid)-$array(pgMajorID)
    set sequences($id) $sequence
    append collector($id) "$array(pgFragment) "

    scan_for_completes
}

proc scan_for_completes {} {
    global collector sequences sequence

    foreach element [array names sequences] {
	if {$sequences($element) + 10 < $sequence} {
	    puts "$element,$collector($element)"
	    puts ""
	    unset sequences($element) collector($element)
	}
    }
}


proc run {} {
    set fp [open /var/log/postgres.log]

    while {[gets $fp line] >= 0} {
	unset -nocomplain array
	#puts $line
	crack_line $line array
	assemble array
    }

    close $fp
}

proc doit {{argv ""}} {
    run
}

if !$tcl_interactive {
    doit $argv
}
