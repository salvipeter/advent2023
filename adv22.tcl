proc zless {a b} {expr {[lindex $a 0 2] - [lindex $b 0 2]}}

# Any match in the X,Y coordinates?
proc above {a b} {
    lassign [lindex $a 0] x0 y0
    lassign [lindex $a 1] x1 y1
    lassign [lindex $b 0] x2 y2
    lassign [lindex $b 1] x3 y3
    if {$x0 == $x1} {
        if {$x2 == $x3} {
            if {$x0 != $x2} {
                return false
            }
            return [expr {$y1 >= $y2 && $y3 >= $y0}]
        }
        return [expr {$x2 <= $x0 && $x0 <= $x3 && $y0 <= $y2 && $y2 <= $y1}]
    }
    if {$y2 == $y3} {
        if {$y0 != $y2} {
            return false
        }
        return [expr {$x1 >= $x2 && $x3 >= $x0}]
    }
    return [expr {$y2 <= $y0 && $y0 <= $y3 && $x0 <= $x2 && $x2 <= $x1}]
}

proc fall {b z} {
    set z0 [lindex $b 0 2]
    set z1 [lindex $b 1 2]
    lset b 0 2 $z
    lset b 1 2 [expr {$z1-$z0+$z}]
    return $b
}

proc reaction {chain falling} {
    set changed false
    for {set b 0} {$b < [llength $chain]} {incr b} {
        if {[lsearch $falling $b] >= 0} {
            continue
        }
        set supported false
        foreach s [lindex $chain $b] {
            if {[lsearch $falling $s] < 0} {
                set supported true
                break
            }
        }
        if {!$supported} {
            lappend falling $b
            set changed true
        }
    }
    if {$changed} {
        tailcall reaction $chain $falling
    } else {
        return $falling
    }
}

set blocks [lmap line [readLines "adv22.txt"] {
    set i [string first ~ $line]
    list [split [string range $line 0 [expr {$i-1}]] ,] \
        [split [string range $line [expr {$i+1}] end] ,]
}]
set blocks [lsort -command zless $blocks]

set chain {}
set unsafe {}
set settled {}
for {set i 0} {$i < [llength $blocks]} {incr i} {
    set b [lindex $blocks $i]
    set maxz 0
    set supports {}
    for {set j 0} {$j < [llength $settled]} {incr j} {
        set s [lindex $settled $j]
        set z [lindex $s 1 2]
        if {$z < $maxz} {
            continue
        }
        if {[above $b $s]} {
            if {$z == $maxz} {
                lappend supports $j
            } else {
                set maxz $z
                set supports [list $j]
            }
        }
    }
    if {[llength $supports] == 1} {
        lappend unsafe [lindex $supports 0]
    }
    if {$maxz == 0} {
        lappend chain ground
    } else {
        lappend chain $supports
    }
    lappend settled [fall $b [expr {$maxz+1}]]
}
puts [expr {[llength $blocks] - [llength [lsort -unique $unsafe]]}]

set sum 0
for {set i 0} {$i < [llength $blocks]} {incr i} {
    incr sum [expr {[llength [reaction $chain [list $i]]] - 1}]
}
puts $sum
