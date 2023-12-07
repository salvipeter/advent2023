# Converts `str` to a digit if starts with one
# (either in digit or string form in Part 2).
# Returns -1 otherwise.
proc toDigit {str} {
    global part2
    set d [string index $str 0]
    if {[string is digit $d]} {
        return $d
    }
    if {$part2} {
        set numbers {zero one two three four five six seven eight nine}
        for {set i 0} {$i < 10} {incr i} {
            set nstr [lindex $numbers $i]
            if {[string match $nstr* $str]} {
                return $i
            }
        }
    }
    return -1
}

# Finds the first and last digits on a line,
# and creates a two-digit number as a result.
proc extractNumber {line} {
    set n [string length $line]
    set digits {}
    for {set i 0} {$i < $n} {incr i} {
        set d [toDigit [string range $line $i end]]
        if {$d >= 0} {
            lappend digits $d
        }
    }
    expr {[lindex $digits 0] * 10 + [lindex $digits end]}
}

set f [open adv01.txt]
set sum 0
while true {
    set line [gets $f]
    if {[eof $f]} {
        close $f
        break
    }
    incr sum [extractNumber $line]
}
puts $sum

