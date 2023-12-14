# Load on the north beams (without extra tilt)
proc northLoad m {
    set size [llength $m]
    set sum 0
    for {set x 0} {$x < $size} {incr x} {
        for {set y 0} {$y < $size} {incr y} {
            if {[string index [lindex $m $y] $x] eq "O"} {
                incr sum [expr {$size-$y}]
            }
        }
    }
    return $sum
}

# Transposes a matrix given as a list of strings
proc transpose m {
    set len [string length [lindex $m 0]]
    set result {}
    for {set y 0} {$y < $len} {incr y} {
        set row ""
        for {set x 0} {$x < [llength $m]} {incr x} {
            append row [string index [lindex $m $x] $y]
        }
        lappend result $row
    }
    return $result
}

proc rotate {m dir} {
    switch $dir {
        left  {lreverse [transpose $m]}
        right {transpose [lreverse $m]}
    }
}

proc tiltWest m {
    set result {}
    set size [llength $m]
    for {set y 0} {$y < $size} {incr y} {
        set row [lindex $m $y]
        set tilted ""
        set fill 0
        for {set x 0} {$x < $size} {incr x} {
            switch [string index $row $x] {
                "." {incr fill}
                "O" {append tilted O}
                "#" {append tilted [string repeat . $fill] #; set fill 0}
            }
        }
        lappend result [string cat $tilted [string repeat . $fill]]
    }
    return $result
}

proc cycle m {
    set m [rotate $m left]
    set m [tiltWest $m]
    set m [rotate $m right]
    set m [tiltWest $m]
    set m [rotate $m right]
    set m [tiltWest $m]
    set m [rotate $m right]
    set m [tiltWest $m]
    set m [rotate $m right]
    set m [rotate $m right]
}

# Part 1
set map [readLines adv14.txt]
puts [northLoad [rotate [tiltWest [rotate $map left]] right]]

# Part 2
set m $map
set cyclen 0
for {set i 0} {!$cyclen} {incr i} {
    set tilted($i) $m
    set m [cycle $m]
    for {set j 0} {$j <= $i} {incr j} {
        if {$tilted($j) == $m} {
            set offset $j
            set cyclen [expr {$i-$j+1}]
            break
        }
    }
}

set n [expr {$offset + (1000000000 - $offset) % $cyclen}]
for {set i 0} {$i < $n} {incr i} {
    set map [cycle $map]
}
puts [northLoad $map]
