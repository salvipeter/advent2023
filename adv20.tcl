proc isFlipFlop module {
    global modules
    lindex [dict get $modules $module] 0
}

proc ends module {
    global modules
    lindex [dict get $modules $module] 1
}

# Sets all internal states to 0 (low signal)
proc initialize {} {
    global modules
    set states [dict create]
    foreach module [dict keys $modules] {
        if {$module eq "broadcaster"} {continue}
        if {[isFlipFlop $module]} {
            dict set states $module 0
        }
        foreach end [ends $module] {
            if {![dict exists $modules $end]} {continue}
            if {![isFlipFlop $end]} {
                if {![dict exists $states $end]} {
                    dict set states $end [dict create]
                }
                dict update states $end state {
                    dict set state $module 0
                }
            }
        }
    }
    return $states
}

proc whoSendsTo name {
    global modules
    set result {}
    foreach from [dict keys $modules] {
        if {[lsearch [ends $from] $name] >= 0} {
            lappend result $from
        }
    }
    return $result
}

# Simulates signal propagation from a button push;
# also checks if any module in `tofind` sends a high signal.
# Returns `{#low #high found}`, where `found` is a list of booleans.
proc pushButton tofind {
    global modules states
    set l 1; set h 0
    set found [lrepeat [llength $tofind] 0]
    set queue [lmap end [dict get $modules broadcaster] {
        list broadcaster $end 0
    }]
    while {$queue != {}} {
        set queue [lassign $queue cmd]
        lassign $cmd whence name signal
        # puts "$whence --$signal--> $name"
        if {$signal} {
            set i [lsearch $tofind $whence]
            if {$i >= 0} {
                lset found $i 1
            }
        }
        if {$signal} {incr h} {incr l}
        if {![dict exists $modules $name]} {continue}
        if {[isFlipFlop $name]} {
            if {$signal} {
                continue
            }
            dict update states $name state {
                set state [expr {!$state}]
                foreach end [ends $name] {
                    lappend queue [list $name $end $state]
                }
            }
        } else {
            dict update states $name state {
                dict set state $whence $signal
                set pulse 0
                if {[lsearch [dict values $state] 0] >= 0} {
                    set pulse 1
                }
                foreach end [ends $name] {
                    lappend queue [list $name $end $pulse]
                }
            }
        }
    }
    list $l $h $found
}

set modules [dict create]
foreach line [readLines adv20.txt] {
    set i [string first " " $line]
    set type [string index $line 0]
    set name [string range $line 1 [expr {$i-1}]]
    set ends [split [regsub -all , [string range $line [expr {$i+4}] end] ""]]
    if {$type eq "b"} {
        dict set modules broadcaster $ends
    } else {
        dict set modules $name [list [expr {$type eq "%"}] $ends]
    }
}
set states [initialize]

# By manual inspection, the data seems to have a specific structure:
# `rx` gets its signal from an inverter, which is connected to
# several conjunctions that give a high signal periodically.
set tofind [whoSendsTo [lindex [whoSendsTo rx] 0]]
set l 0; set h 0
set part2 1
for {set i 1} {$tofind != {}} {incr i} {
    lassign [pushButton $tofind] dl dh found
    incr l $dl; incr h $dh
    if {$i == 1000} {
        set part1 [expr {$l*$h}]
    }
    set remaining {}
    for {set j 0} {$j < [llength $found]} {incr j} {
        if {[lindex $found $j]} {
            set part2 [expr {$part2*$i}]
        } else {
            lappend remaining [lindex $tofind $j]
        }
    }
    set tofind $remaining
}
puts "$part1 $part2"
