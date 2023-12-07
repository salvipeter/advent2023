proc value card {
    global part2
    switch $card {
        A {return 14}
        K {return 13}
        Q {return 12}
        J {return [expr {$part2 ? 1 : 11}]}
        T {return 10}
        default {return $card}
    }
}

# Predicate to decide whether `cards` contain
# exactly `n` cards of the same value.
# If yes, and `remove` is true, return the rest.
proc findExactlyN {cards n {remove false}} {
    global part2
    for {set v 2} {$v <= 14} {incr v} {
        set count 0
        set rest {}
        foreach c $cards {
            if {[value $c] == $v || $part2 && $c == "J"} {
                incr count
            } else {
                lappend rest $c
            }
        }
        if {$count == $n} {
            if {$remove} {
                return $rest
            }
            return true
        }
    }
    return false
}

# Return the rank of the hand, where
# High card is 1, and Five of a kind is 7.
proc type cards {
    if {[findExactlyN $cards 5]} {return 7}
    if {[findExactlyN $cards 4]} {return 6}
    set rest [findExactlyN $cards 3 true]
    if {$rest != false && [findExactlyN $rest 2]} {return 5}
    if {$rest != false} {return 4}
    set rest [findExactlyN $cards 2 true]
    if {$rest == false} {return 1}
    if {[findExactlyN $rest 2]} {return 3}
    return 2
}

proc compare {hand1 hand2} {
    set a [split [lindex $hand1 0] ""]
    set b [split [lindex $hand2 0] ""]
    if {[type $a] != [type $b]} {
        return [expr {[type $a]-[type $b]}]
    }
    foreach x $a y $b {
        if {[value $x] != [value $y]} {
            return [expr {[value $x]-[value $y]}]
        }
    }
}

set f [open adv07.txt]
set hands [split [read -nonewline $f] "\n"]
close $f
set sorted [lsort -command compare $hands]
set sum 0
for {set i 0} {$i < [llength $sorted]} {incr i} {
    incr sum [expr {($i+1)*[lindex $sorted $i 1]}]
}
puts $sum
