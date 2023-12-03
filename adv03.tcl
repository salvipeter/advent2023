set f [open adv03.txt]
set engine [split [read -nonewline $f] "\n"]
close $f

set width [string length [lindex $engine 0]]
set height [llength $engine]

proc inside {x y} {
    global width height
    expr {$x >= 0 && $x < $width && $y >= 0 && $y < $height}
}

proc special {x y} {
    global engine
    if {![inside $x $y]} {
        return false
    }
    set c [string index [lindex $engine $y] $x]
    if {[string is digit $c] || $c == "."} {
        return false
    }
    return true
}

# Checks if there is a special character
# adjacent to the given range.
proc check {y x1 x2} {
    incr x1 -1
    incr x2 1
    set y1 [expr {$y-1}]
    set y2 [expr {$y+1}]
    if {[special $x1 $y] || [special $x2 $y]} {
        return true
    }
    for {set i $x1} {$i <= $x2} {incr i} {
        if {[special $i $y1] || [special $i $y2]} {
            return true
        }
    }
    return false
}

# The ending index of the number starting at index `i`.
# Returns `i-1` if there is no number starting there.
proc endIndex {str i} {
    set tail [string range $str $i end]
    if {[string is digit -failindex len $tail]} {
        return [expr {$i+[string length $tail]-1}]
    }
    return [expr {$i+$len-1}]
}

set sum 0
for {set y 0} {$y < $height} {incr y} {
    set line [lindex $engine $y]
    for {set x 0} {$x < $width} {incr x} {
        set x2 [endIndex $line $x]
        if {$x2 >= $x} {
            if {[check $y $x $x2]} {
                incr sum [string range $line $x $x2]
            }
            set x $x2
        }
    }
}
puts $sum

# Part 2

# Computes the number that starts somewhere to the left.
# Returns -1 if there is no number at the given point.
proc getnum {x y} {
    global engine
    if {![inside $x $y]} {
        return -1
    }
    set line [lindex $engine $y]
    if {![string is digit [string index $line $x]]} {
        return -1
    }
    while {$x >= 0 && [string is digit [string index $line $x]]} {
        incr x -1
    }
    incr x
    string range $line $x [endIndex $line $x]
}

# Returns all numbers adjacent to the given coordinates.
# Care is taken s.t. each number is returned only once.
proc adjacent {x y} {
    set result {}
    for {set dy -1} {$dy <= 1} {incr dy} {
        set y2 [expr {$y+$dy}]
        for {set dx -1} {$dx <= 1} {incr dx} {
            set x2 [expr {$x+$dx}]
            set n [getnum $x2 $y2]
            if {$n >= 0 && ($dx == -1 || [getnum [expr {$x2-1}] $y2] < 0)} {
                lappend result $n
            }
        }
    }
    return $result 
}

set sum 0
for {set y 0} {$y < $height} {incr y} {
    set line [lindex $engine $y]
    for {set x 0} {$x < $width} {incr x} {
        if {[string index $line $x] == "*"} {
            set nums [adjacent $x $y]
            if {[llength $nums] == 2} {
                lassign $nums a b
                incr sum [expr {$a*$b}]
            }
        }
    }
}
puts $sum
