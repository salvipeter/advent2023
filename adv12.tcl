source readlines.tcl
set part2 false

# Try to locate the `n` > 0 good springs
# Assumption: first `len` characters are OK
proc tryAndCount {springs groups n len} {
    if {[llength $groups] > $n + 1} {
        return 0
    }
    if {$groups == {}} {
        return [expr {[string first # $springs $len] < 0 ? 1 : 0}]
    }
    set rest [lassign $groups g]
    set sum 0
    for {set k 0} {$k <= $n} {incr k} {
        set d1 [expr {$len+$k-1}]
        set s1 [string range $springs $len $d1]
        if {[string first # $s1] >= 0} {
            break
        }
        set d2 [expr {$d1+$g}]
        incr d1
        set s2 [string range $springs $d1 $d2]
        if {[string first . $s2] >= 0} {
            continue
        }
        incr d2
        if {$k == $n} {
            incr sum [expr {$rest == {} ? 1 : 0}]
        } elseif {[string index $springs $d2] != "#"} {
            incr d2
            incr sum [tryAndCount $springs $rest [expr {$n-$k-1}] $d2]
        }
    }
    return $sum
}

proc arrangements line {
    global part2
    set springs [lindex $line 0]
    set groups [split [lindex $line 1] ,]
    if {$part2} {
        set springs [join [lrepeat 5 $springs] ?]
        set groups [lrepeat 5 {*}$groups]
    }
    set len [string length $springs]
    set sum 0
    foreach g $groups {
        incr sum $g
    }
    tryAndCount $springs $groups [expr {$len-$sum}] 0
}

set sum 0
foreach line [readLines adv12.txt] {
    incr sum [arrangements $line]
}
puts $sum
