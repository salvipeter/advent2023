# Transposes a matrix given as a list of strings
proc transpose m {
    set len [string length [lindex $m 0]]
    set result {}
    for {set y 0} {$y < $len} {incr y} {
        set row ""
        for {set x 0} {$x < [llength $m]} {incr x} {
            append row [string index [lindex $m $x] $y]
        }
        lappend result $row
    }
    return $result
}

# Finds a horizontal line of symmetry (but not `except`)
# in matrix `m`; return 0 otherwise.
proc symmetry {m {except 0}} {
    set h [llength $m]
    for {set i 1} {$i < $h} {incr i} {
        if {$i == $except} {
            continue
        }
        set ok 1
        set min [expr {max(0, $i-($h-$i))}]
        for {set j $min} {$j < $i} {incr j} {
            set k [expr {$i-$j+$i-1}]
            if {[lindex $m $j] ne [lindex $m $k]} {
                set ok 0
                break
            }
        }
        if {$ok} {
            return $i
        }
    }
    return 0
}

# Toggles the `i`-th character of `s` between "." and "#".
proc flip {s i} {
    if {[string index $s $i] eq "#"} {
        string replace $s $i $i .
    } else {
        string replace $s $i $i #
    }
}

proc clearSmudge m {
    set s [symmetry $m]
    set st [symmetry [transpose $m]]
    set h [llength $m]
    set w [string length [lindex $m 0]]
    for {set y 0} {$y < $h} {incr y} {
        set row [lindex $m $y]
        for {set x 0} {$x < $w} {incr x} {
            set clean [flip $row $x]
            lset m $y $clean
            set r [symmetry $m $s]
            if {$r > 0} {
                return [expr {100*$r}]
            }
            set r [symmetry [transpose $m] $st]
            if {$r > 0} {
                return $r
            }
            lset m $y $row
        }
    }
}

set sum 0
set lines [readLines adv13.txt]
while {$lines != {}} {
    set i [lsearch $lines {}]
    if {$i < 0} {
        set m $lines
        set lines {}
    } else {
        set m [lrange $lines 0 [expr {$i-1}]]
        set lines [lrange $lines [expr {$i+1}] end]
    }
    if {$part2} {
        incr sum [clearSmudge $m]
    } else {
        incr sum [expr {100 * [symmetry $m] + [symmetry [transpose $m]]}]
    }
}
puts $sum
