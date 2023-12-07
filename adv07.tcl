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

# Predicate to decide whether `$var` contains
# exactly `n` cards of the same value.
# If yes, remove those cards from the variable.
proc findExactlyN {var n} {
    global part2
    upvar $var cards
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
            set cards $rest
            return true
        }
    }
    return false
}

# Return the rank of the hand, where
# High card is 1, and Five of a kind is 7.
proc type cards {
    if {[findExactlyN cards 5]} {return 7}
    if {[findExactlyN cards 4]} {return 6}
    if {[findExactlyN cards 3] && [findExactlyN cards 2]} {return 5}
    if {[llength $cards] == 2} {return 4}
    if {[findExactlyN cards 2] && [findExactlyN cards 2]} {return 3}
    if {[llength $cards] == 3} {return 2}
    return 1
}

proc score hand {
    set cards [split [lindex $hand 0] ""]
    set result [expr {100**5*[type $cards]}]
    foreach c $cards i {4 3 2 1 0} {
        incr result [expr {100**$i*[value $c]}]
    }
    lset hand 0 $result
}

set f [open adv07.txt]
set hands [split [read -nonewline $f] "\n"]
close $f
set sorted [lsort [lmap hand $hands {score $hand}]]
set sum 0
for {set i 0} {$i < [llength $sorted]} {incr i} {
    incr sum [expr {($i+1)*[lindex $sorted $i 1]}]
}
puts $sum
