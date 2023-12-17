# Direction is one of: 0 - up, 1 - right, 2 - down, 3 - left
proc step {pos dir} {
    lassign $pos x y
    lassign [lindex {{0 -1} {1 0} {0 1} {-1 0}} $dir] dx dy
    incr x $dx
    incr y $dy
    list $x $y
}

# For positions outside the map, return the empty string
proc get pos {
    global map
    lassign $pos x y
    lindex $map $y $x
}

# Try to step `n` steps in direction `dir` from `pos`.
# Return `{newposdir weight}` or `{}` if invalid.
proc weightedStep {pos dir n} {
    set sum 0
    for {set i 0} {$i < $n} {incr i} {
        set pos [step $pos $dir]
        set w [get $pos]
        if {$w == {}} {
            return {}
        }
        incr sum $w
    }
    list [concat $pos $dir] $sum
}

proc popSmallest {var cost} {
    upvar $var xs
    set min -1
    for {set i 0} {$i < [llength $xs]} {incr i} {
        set x [lindex $xs $i]
        set w [dict get $cost $x]
        if {$min < 0 || $w < $min} {
            set min $w
            set mini $i
        }
    }
    set x [lindex $xs $mini]
    set xs [lreplace $xs $mini $mini ]
    return $x
}

# A "point" consists of 3 numbers: `{x y d}`,
# where `d` is the direction taken to arrive there.
proc shortestPath {from to} {
    global edges
    set queue [list $from]
    set cost [dict create $from 0]
    set visited [dict create]
    while {$queue != {}} {
        set p0 [popSmallest queue $cost]
        if {[dict exists $visited $p0]} {
            continue
        }
        set w0 [dict get $cost $p0]
        foreach pw [dict get $edges $p0] {
            lassign $pw p w
            if {[dict exists $visited $p]} {
                continue
            }
            if {![dict exists $cost $p] || $w0 + $w < [dict get $cost $p]} {
                dict set cost $p [expr {$w0 + $w}]
                lappend queue $p
            }
        }
        dict set visited $p0 1
    }
    set min -1
    foreach i {0 1 2 3} {
        set p [concat $to $i]
        if {![dict exists $cost $p]} {
            continue
        }
        set d [dict get $cost $p]
        if {$min < 0 || $d < $min} {
            set min $d
        }
    }
    return $min
}

set map [lmap line [readLines adv17.txt] {split $line ""}]
set size [expr {[llength $map] - 1}]

if {$part2} {
    set min 4
    set max 10
} else {
    set min 1
    set max 3
}

set edges [dict create]
for {set x 0} {$x <= $size} {incr x} {
    for {set y 0} {$y <= $size} {incr y} {
        set p [list $x $y]
        dict set edges $p {}
        foreach d {0 1 2 3} {
            set pd [concat $p $d]
            dict set edges $pd {}
            set d1 [expr {($d+1)%4}]
            set d2 [expr {($d+3)%4}]
            for {set i $min} {$i <= $max} {incr i} {
                set ws1 [weightedStep $p $d1 $i]
                set ws2 [weightedStep $p $d2 $i]
                if {$ws1 != {}} {
                    dict lappend edges $p $ws1
                    dict lappend edges $pd $ws1
                }
                if {$ws2 != {}} {
                    dict lappend edges $p $ws2
                    dict lappend edges $pd $ws2
                }
            }
        }
    }
}

puts [shortestPath {0 0} [list $size $size]]
