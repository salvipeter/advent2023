proc seedify seeds {
    global part2
    if {!$part2} {
        return [lmap x $seeds {list $x 1}]
    }
    set result {}
    foreach {i j} $seeds {
        lappend result [list $i $j]
    }
    return $result
}

proc convert {rules old newname} {
    upvar $newname new
    lassign $rules dest src len
    set rest {}
    foreach v $old {
        lassign $v x xlen
        set x1 [expr {max($x,$src)}]
        set x2 [expr {min($x+$xlen,$src+$len)}]
        if {$x2 < $x1} {
            lappend rest $v
            continue
        }
        if {$x1 < $src+$len && $x2 >= $src} {
            lappend new [list [expr {$x1-$src+$dest}] [expr {$x2-$x1}]]
        }
        if {$x < $x1} {
            lappend rest [list $x [expr {$x1-$x}]]
        }
        if {$x2 < $x+$xlen} {
            lappend rest [list $x2 [expr {$x+$xlen-$x2}]]
        }
    }
    return $rest
}

set lines [readLines adv05.txt]
set x [seedify [lrange [lindex $lines 0] 1 end]]
set y {}
for {set i 3} {$i < [llength $lines]} {incr i} {
    set line [lindex $lines $i]
    if {$line == ""} {
        set x [concat $x $y]
        set y {}
        incr i
    } else {
        set x [convert $line $x y]
    }
}
set x [concat $x $y]
puts [::tcl::mathfunc::min {*}[lmap n $x {lindex $n 0}]]
