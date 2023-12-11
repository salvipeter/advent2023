proc galaxy {x y} {
    global map
    set c [string index [lindex $map $y] $x]
    expr {$c == "#"}
}

proc before {pos pos2} {
    lassign $pos x y
    lassign $pos2 x2 y2
    expr {$y < $y2 || ($y == $y2 && $x <= $x2)}
}

proc distance {pos pos2} {
    global emptyRows emptyCols part2
    set expansion [expr {$part2 ? 999999 : 1}]
    lassign $pos x y
    lassign $pos2 x2 y2
    set d [expr {abs($x2-$x)+abs($y2-$y)}]
    foreach e $emptyRows {
        if {$y < $e && $e < $y2 || $y2 < $e && $e < $y} {
            incr d $expansion
        }
    }
    foreach e $emptyCols {
        if {$x < $e && $e < $x2 || $x2 < $e && $e < $x} {
            incr d $expansion
        }
    }
    return $d
}

set map [readLines adv11.txt]
set height [llength $map]
set width [string length [lindex $map 0]]

set emptyRows {}
for {set y 0} {$y < $height} {incr y} {
    if {[string first # [lindex $map $y]] < 0} {
        lappend emptyRows $y
    }
}
set emptyCols {}
for {set x 0} {$x < $width} {incr x} {
    if {"#" ni [lmap row $map {string index $row $x}]} {
        lappend emptyCols $x
    }
}

set galaxies {}
for {set y 0} {$y < $height} {incr y} {
    for {set x 0} {$x < $width} {incr x} {
        if {[galaxy $x $y]} {
            lappend galaxies [list $x $y]
        }
    }
}

set sum 0
foreach pos $galaxies {
    foreach pos2 $galaxies {
        if {[before $pos2 $pos]} {
            continue
        }
        incr sum [distance $pos $pos2]
    }
}
puts $sum
