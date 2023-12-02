set part1 true

proc possible {line red green blue} {
    global part1
    set id [scan [string range $line 5 end] "%d"]
    set start [expr {[string first ":" $line] + 2}]
    set line [string range $line $start end]
    set game [lmap cubes [split $line ";"] {split $cubes ,}]
    foreach cubes $game {
        foreach cube $cubes {
            lassign $cube n color
            if {$n > [set $color]} {
                if {$part1} {
                    return 0
                }
                set $color $n
            }
        }
    }
    expr {$part1 ? $id : $red * $green * $blue}
}

set sum 0
set base [if {$part1} {list 12 13 14} {list 0 0 0}]
set f [open adv02.txt]
while true {
    set line [gets $f]
    if {[eof $f]} {
        close $f
        break
    }
    incr sum [possible $line {*}$base]
}
puts $sum

