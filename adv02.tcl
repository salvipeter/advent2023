proc possible {line red green blue} {
    global part2
    set id [scan [string range $line 5 end] "%d"]
    set start [expr {[string first ":" $line] + 2}]
    set line [string range $line $start end]
    set game [lmap cubes [split $line ";"] {split $cubes ,}]
    foreach cubes $game {
        foreach cube $cubes {
            lassign $cube n color
            if {$n > [set $color]} {
                if {!$part2} {
                    return 0
                }
                set $color $n
            }
        }
    }
    expr {$part2 ? $red * $green * $blue : $id}
}

set sum 0
set base [if {$part2} {list 0 0 0} {list 12 13 14}]
foreach line [readLines adv02.txt] {
    incr sum [possible $line {*}$base]
}
puts $sum

