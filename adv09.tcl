proc extrapolate vals {
    global part2
    set diffs {}
    set allzero true
    foreach a $vals b [lrange $vals 1 end] {
        if {$a != 0} {set allzero false}
        if {$b != {}} {
            lappend diffs [expr {$b-$a}]
        }
    }
    if {$allzero} {
        return 0
    }
    if {$part2} {
        expr {[lindex $vals 0] - [extrapolate $diffs]}
    } else {
        expr {[lindex $vals end] + [extrapolate $diffs]}
    }
}

set sum 0
set f [open adv09.txt]
while true {
    set line [gets $f]
    if {[eof $f]} {
        close $f
        break
    }
    incr sum [extrapolate $line]
}
puts $sum
