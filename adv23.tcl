proc get {x y} {
    global map
    string index [lindex $map $y] $x
}

proc adjacent pos {
    global part2
    set result {}
    lassign $pos x y
    set terrain [get $x $y]
    foreach dx {0 1 0 -1} dy {-1 0 1 0} s {^ > v <} {
        if {!$part2 && $terrain ne "." && $terrain ne $s} {
            continue
        }
        set x2 [expr {$x+$dx}]
        set y2 [expr {$y+$dy}]
        set terrain2 [get $x2 $y2]
        if {$terrain2 ne "#" && $terrain2 ne ""} {
            lappend result [list $x2 $y2]
        }
    }
    return $result
}

# Returns {crossroad prev length neighbors},
# or: {} at a dead end, or length if path leads to the goal
set cache [dict create]
proc crossroads {from to prev} {
    global cache
    set index [list $from $prev]
    if {[dict exists $cache $index]} {
        return [dict get $cache $index]
    }
    set len 0
    while true {
        if {$from == {}} {
            set result {}
            break
        }
        if {$from == $to} {
            set result $len
            break
        }
        incr len
        set neighbors [adjacent $from]
        if {[llength $neighbors] > 2} {
            set result [list $from $prev $len $neighbors]
            break
        }
        lassign $neighbors a b
        if {$a == $prev} {
            set prev $from
            set from $b
        } else {
            set prev $from
            set from $a
        }
    }
    dict set cache $index $result
    return $result
}

proc longest {from to {visited {}}} {
    set prev [lindex $visited end]
    lassign [crossroads $from $to $prev] from prev len neighbors
    if {[llength $from] != 2} {
        return $from
    }
    if {[lsearch $visited $from] >= 0} {
        return {}
    }
    lappend visited $from
    set max -1
    foreach path $neighbors {
        if {$path == $prev} {
            continue
        }
        set rest [longest $path $to $visited]
        if {$rest != {}} {
            if {$max < 0 || $rest > $max} {
                set max $rest
            }
        }
    }
    if {$max < 0} {
        return {}
    }
    return [expr {$len+$max}]
}

set map [readLines adv23.txt]
set size [llength $map]
set from {1 0}
set to [list [expr {$size-2}] [expr {$size-1}]]
puts [longest $from $to]
