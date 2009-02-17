#
#
#
#
# $Id: main.tcl,v 1.5 2009-02-17 03:36:02 karl Exp $
#

package require Tclx
#catch {parray foo}
#cmdtrace on

if {[info exists ::launchdir]} {
    cd $::launchdir
}

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

#
# emit - emit the line unless there are patterns and it doesn't match
#
proc emit {key value} {
    global patterns

    if {[llength $patterns]} {
	set matched 0
	foreach pattern $patterns {
	    if {[regexp $pattern $value]} {
		set matched 1
		break
	    }
	}

	if {!$matched} {
	    return
	}
    }

    puts "$key,$value"
    puts ""
}

#
# scan_for_completes - look at the sequences currently being assembled
#  and if any are more than some amount "older" (based on sequence
#  number that we increment when we see the first line of a group
#  of lines), emit
#
proc scan_for_completes {} {
    global collector sequences sequence

    foreach element [array names sequences] {
	if {$sequences($element) + 10 < $sequence} {
	    emit $element $collector($element)
	    unset sequences($element) collector($element)
	}
    }
}

#
# run - start tailing the postgres log file
#
proc run {} {
    set logfp [open "|tail -f /var/log/postgres.log"]
    #set logfp [open /var/log/postgres.log]

    while {[gets $logfp line] >= 0} {
	unset -nocomplain array
	#puts $line
	crack_line $line array
	assemble array
    }

    close $logfp
}

proc doit {{argv ""}} {
    global patterns

    if {$argv == ""} {
	set patterns ""
    } else {
	set patterns $argv
    }

    run
}

if !$tcl_interactive {
    doit $argv
}
