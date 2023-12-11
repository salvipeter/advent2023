proc distance {a b} {
    global emptyCols emptyRows part2
    set expansion [expr {$part2 ? 999999 : 1}]
    lassign $a ax ay
    lassign $b bx by
    set d [expr {abs($bx-$ax)+abs($by-$ay)}]
    foreach e $emptyCols {
        if {$ax < $e && $e < $bx || $bx < $e && $e < $ax} {
            incr d $expansion
        }
    }
    foreach e $emptyRows {
        if {$ay < $e && $e < $by || $by < $e && $e < $ay} {
            incr d $expansion
        }
    }
    return $d
}

set map [readLines adv11.txt]
set height [llength $map]
set width [string length [lindex $map 0]]

set emptyCols {}
set emptyRows {}
set galaxies {}
for {set x 0} {$x < $width} {incr x} {
    if {"#" ni [lmap row $map {string index $row $x}]} {
        lappend emptyCols $x
    }
}
for {set y 0} {$y < $height} {incr y} {
    if {[string first # [lindex $map $y]] < 0} {
        lappend emptyRows $y
    }
    for {set x 0} {$x < $width} {incr x} {
        if {[string index [lindex $map $y] $x] eq "#"} {
            lappend galaxies [list $x $y]
        }
    }
}

set sum 0
while {$galaxies != {}} {
    set p [lindex $galaxies 0]
    set galaxies [lrange $galaxies 1 end]
    foreach q $galaxies {
        incr sum [distance $p $q]
    }
}
puts $sum
