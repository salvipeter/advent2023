# Direction is one of: 0 - up, 1 - right, 2 - down, 3 - left
proc step {pos dir} {
    lassign $pos x y
    lassign [lindex {{0 -1} {1 0} {0 1} {-1 0}} $dir] dx dy
    incr x $dx
    incr y $dy
    list $x $y
}

# For positions outside the map, return the empty string
proc get pos {
    global map
    lassign $pos x y
    lindex $map $y $x
}

proc simulate {pos dir acc} {
    while true {
        set c [get $pos]
        if {$c eq ""} {
            break
        }
        if {[dict exists $acc $pos]} {
            set dirs [dict get $acc $pos]
            if {[lsearch $dirs $dir] >= 0} {
                break
            } else {
                dict set acc $pos [concat $dirs $dir]
            }
        } else {
            dict set acc $pos $dir
        }
        switch [get $pos] {
            /  {set dir [lindex {1 0 3 2} $dir]}
            \\ {set dir [lindex {3 2 1 0} $dir]}
            -  {if {$dir % 2 == 0} {
                    set acc [simulate [step $pos 1] 1 $acc]
                    set dir 3
                }}
            |  {if {$dir % 2 == 1} {
                    set acc [simulate [step $pos 0] 0 $acc]
                    set dir 2
                }}
        }
        set pos [step $pos $dir]
    }
    return $acc
}

set map [lmap line [readLines adv16.txt] {split $line ""}]
set size [expr {[llength $map]-1}]
set max 0
for {set i 0} {$i <= $size} {incr i} {
    puts "$i..."
    set a [dict size [simulate "$i $size" 0 [dict create]]]
    set b [dict size [simulate "0 $i" 1 [dict create]]]
    if {$i == 0} {puts $b}; # Part 1
    set c [dict size [simulate "$i 0" 2 [dict create]]]
    set d [dict size [simulate "$size $i" 3 [dict create]]]
    set max [expr {max($max,$a,$b,$c,$d)}]
}
puts $max
