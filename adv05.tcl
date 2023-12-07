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

set f [open adv05.txt]
set line [gets $f]
set x [seedify [lrange $line 1 end]]
gets $f; # empty line
gets $f; # header

set y {}
while true {
    set line [gets $f]
    if {[eof $f]} {
        close $f
        set x [concat $x $y]
        break
    }
    if {$line == ""} {
        set x [concat $x $y]
        set y {}
        gets $f; # header
    } else {
        set x [convert $line $x y]
    }
}
puts [::tcl::mathfunc::min {*}[lmap n $x {lindex $n 0}]]
