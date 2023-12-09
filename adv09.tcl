proc extrapolate vals {
    global part2
    if {[lsearch -not 0 $vals] < 0} {return 0}
    set diffs {}
    foreach a [lrange $vals 0 end-1] b [lrange $vals 1 end] {
        lappend diffs [expr {$b-$a}]
    }
    set dx [extrapolate $diffs]
    expr {$part2 ? [lindex $vals 0]-$dx : [lindex $vals end]+$dx}
}

set sum 0
foreach line [readLines adv09.txt] {
    incr sum [extrapolate $line]
}
puts $sum
