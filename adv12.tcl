source readlines.tcl

# Note: `acc == 0 || acc <= [lindex $groups 0]` always holds
proc tryAndCount {springs groups acc} {
    if {$groups == {}} {
        return [expr {[string first # $springs] < 0 ? 1 : 0}]
    } 
    if {$springs == ""} {
        return [expr {$groups == $acc ? 1 : 0}]
    }
    set s [string index $springs 0]
    set srest [string range $springs 1 end]
    set g [lindex $groups 0]
    set grest [lrange $groups 1 end]
    if {$s == "."} {
        if {$acc == 0} {
            tailcall tryAndCount $srest $groups 0
        } elseif {$g == $acc} {
            tailcall tryAndCount $srest $grest 0
        } else {
            return 0
        }
    } elseif {$s == "#"} {
        if {$acc < $g} {
            tailcall tryAndCount $srest $groups [expr {$acc+1}]
        } else {
            return 0
        }
    } else {
        if {$acc == $g} {
            tailcall tryAndCount $srest $grest 0
        }
        set sum [tryAndCount $srest $groups [expr {$acc+1}]]
        if {$acc == 0} {
            incr sum [tryAndCount $srest $groups 0]
        }
        return $sum
    }
}

proc arrangements line {
    global part2
    set springs [lindex $line 0]
    set groups [split [lindex $line 1] ,]
    if {$part2} {
        set springs [join [lrepeat 5 $springs] ?]
        set groups [lrepeat 5 {*}$groups]
    }
    tryAndCount $springs $groups 0
}

set sum 0
foreach line [readLines adv12.txt] {
    incr sum [arrangements $line]
}
puts $sum
