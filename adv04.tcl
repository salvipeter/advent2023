set f [open adv04.txt]
set allcards [split [read -nonewline $f] "\n"]
close $f

set cache [dict create]

proc win {i} {
    global allcards cache part2
    if {[dict exists $cache $i]} {
        return [dict get $cache $i]
    }
    set line [lindex $allcards $i]
    set wins [lrange $line 2 11]
    set cards [lrange $line 13 end]
    set count 0
    foreach c $cards {
        if {[lsearch -integer $wins $c] >= 0} {
            incr count
        }
    }
    if {$part2} {
        set sum 0
        for {set j 1} {$j <= $count} {incr j} {
            incr sum [win [expr {$i+$j}]]
        }
        set result [expr {1+$sum}]
    } else {
        set result [expr {$count > 0 ? 1<<($count-1) : 0}]
    }
    dict set cache $i $result
    return $result
}

set sum 0
for {set i 0} {$i < [llength $allcards]} {incr i} {
    incr sum [win $i]
}
puts $sum

