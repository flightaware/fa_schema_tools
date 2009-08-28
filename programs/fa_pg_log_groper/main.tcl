#
# fa_pg_log_groper - this will grep postgresql potentially multi-line messages
# out of the syslog and assemble them back into single lines
#

# the number of messages we assemble simultaneously, after the nth message
# is received, the first one is output, etc.
set queueSize 10

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
	if {$sequences($element) + $::queueSize < $sequence} {
	    emit $element $collector($element)
	    unset sequences($element) collector($element)
	}
    }
}

#
# line_available
#
proc line_available {logfp} {
    if {[eof $logfp]} {
	eof_exit
    }

    if {[gets $logfp line] >= 0} {
	#puts $line
	crack_line $line array
	assemble array
    }
}

#
# one_second_interval - get called every second and increment the sequence
#  to force output when not much stuff is coming in
#
proc one_second_interval {} {
    global sequence

    after 1000 one_second_interval

    incr sequence
    scan_for_completes
}

#
# eof_exit
#
proc eof_exit {} {
    set ::die 1
}


#
# run - start tailing the postgres log file
#
proc run {} {
    set logfp [open "|tail -f /var/log/postgres.log"]
    #set logfp [open /var/log/postgres.log]
    fconfigure $logfp -blocking 0
    fileevent $logfp readable "line_available $logfp"

    one_second_interval
}

proc doit {{argv ""}} {
    global patterns

    if {$argv == ""} {
	set patterns ""
    } else {
	set patterns $argv
    }

    run

    vwait die
    exit 0
}

if !$tcl_interactive {
    doit $argv
}
