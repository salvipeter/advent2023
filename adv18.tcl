proc step {pos dir n} {
    lassign $pos x y
    switch $dir {
        U {return [list $x [expr {$y-$n}]]}
        R {return [list [expr {$x+$n}] $y]}
        D {return [list $x [expr {$y+$n}]]}
        L {return [list [expr {$x-$n}] $y]}
    }
}

proc distance {p q} {
    lassign $p x1 y1
    lassign $q x2 y2
    expr {abs($x1-$x2)+abs($y1-$y2)}
}

# y-coordinate is checked first
proc less {p q} {
    lassign $p x1 y1
    lassign $q x2 y2
    expr {$y1 < $y2 || $y1 == $y2 && $x1 < $x2}
}

# `p` is inside the `(a,b]` rectangle
proc inside {p a b} {
    lassign $p x y
    lassign $a x1 y1
    lassign $b x2 y2
    expr {$x1<$x && $x<=$x2 && $y1<$y && $y<=$y2}
}

# Returns the top-left point in the `(a,b]` rectangle
# If range is not given, the whole map is assumed.
proc topLeft {{a {}} {b {}}} {
    global segments
    set result {}
    foreach s $segments {
        foreach p $s {
            if {$a != {} && ![inside $p $a $b]} {
                continue
            }
            if {$result == {} || [less $p $result]} {
                set result $p
            }
        }
    }
    return $result
}

# Remove all segments connected to `pos`,
# and returns their other endpoints.
proc remove pos {
    global segments
    set result {}
    set updated {}
    foreach s $segments {
        lassign $s p q
        if {$p == $pos} {
            lappend result $q
        } elseif {$q == $pos} {
            lappend result $p
        } else {
            lappend updated $s
        }
    }
    set segments $updated
    return $result
}

# Number of strictly interior points in [a,b]
proc interior {a b} {
    lassign $a x1 y1
    lassign $b x2 y2
    expr {($x2-$x1-1)*($y2-$y1-1)}
}

# Clips off the top-left rectangle, and returns its interior size
proc clipRectangle {} {
    global segments
    set a [topLeft]
    lassign [remove $a] p1 p2
    if {[lindex $a 0] == [lindex $p2 0]} {
        lassign [list $p2 $p1] p1 p2
    }
    # `p1` is the vertical, `p2` the horizontal endpoint
    set b [list [lindex $p2 0] [lindex $p1 1]]
    set q [topLeft $a $b]
    if {$q == {}} {
        # Case #1: no corner in (a,b]
        lassign [remove $p1] q1
        lassign [remove $p2] q2
        lappend segments [list $q1 $b]
        lappend segments [list $b $q2]
        return [expr {[interior $a $b]+[distance $p1 $b]-1}]
    }
    lassign [remove $q] q1 q2
    if {$q1 == $p1 && $q2 == $p2 || $q1 == $p2 && $q2 == $p1} {
        # Case 2: connects to the left and the top
        return [interior $a $q]
    }
    if {$q1 == $p1 || $q2 == $p1} {
        # Case 3: connects to the left
        if {$q1 == $p1} {set q1 $q2}
        set q2 [list [lindex $q 0] [lindex $a 1]]
        lappend segments [list $q1 $q2]
        if {$q2 != $p2} {
            lappend segments [list $q2 $p2]
        }
        return [expr {[interior $a $q]+[distance $q $q2]-1}]
    }
    if {$q1 == $p2 || $q2 == $p2} {
        # Case 4: connects to the top
        if {$q1 == $p2} {set q1 $q2}
        set q2 [list [lindex $a 0] [lindex $q 1]]
        if {$q2 != $p1} {
            lappend segments [list $q1 $q2]
            lappend segments [list $q2 $p1]
        } else {
            lassign [remove $p1] r
            lappend segments [list $r $q1]
        }
        return [expr {[interior $a $q]+[distance $q $q2]-1}]
    }
    # Case 5: no connection
    if {[lindex $q 0] == [lindex $q2 0]} {
        lassign [list $q2 $q1] q1 q2
    }
    set r1 [list [lindex $a 0] [lindex $q 1]]
    set r2 [list [lindex $q 0] [lindex $a 1]]
    if {$p1 != $r1} {
        lappend segments [list $p1 $r1]
        lappend segments [list $r1 $q]
    } else {
        lassign [remove $p1] r
        lappend segments [list $r $q]
    }
    lappend segments [list $q $q2]
    if {$p2 != $r2} {
        lappend segments [list $p2 $r2]
    }
    lappend segments [list $r2 $q]
    lappend segments [list $q $q1]
    expr {[interior $a $q]+[distance $q $r1]+[distance $q $r2]-2}
}

set pos {0 0}
set count 0
set segments {}
foreach line [readLines adv18.txt] {
    if {$part2} {
        set dir [lindex {R D L U} [string index [lindex $line 2] end-1]]
        set steps [scan [string range [lindex $line 2] 2 end-2] %x]
    } else {
        set dir [lindex $line 0]
        set steps [lindex $line 1]
    }
    set p [step $pos $dir $steps]
    lappend segments [list $pos $p]
    incr count [distance $pos $p]
    set pos $p
}

while {$segments != {}} {
    incr count [clipRectangle]
}
puts $count
