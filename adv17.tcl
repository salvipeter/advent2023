source readlines.tcl

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

# All valid neighbors, considering the path taken;
# also return the new path and the weight.
proc adjacent pospath {
    set result {}
    lassign $pospath pos path
    lassign $pos x y
    foreach d {0 1 2 3} {
        if {$path == "$d $d $d" || [lindex $path end] == ($d+2)%4} {
            continue
        }
        set p [step $pos $d]
        set w [get $p]
        if {$w != {}} {
            if {[lindex $path end] == $d} {
                set newpath [concat [lrange $path end-1 end] $d]
            } else {
                set newpath [list $d]
            }
            lappend result [list [list $p $newpath] $w]
        }
    }
    return $result
}

proc popSmallest {var cost} {
    upvar $var xs
    set min -1
    for {set i 0} {$i < [llength $xs]} {incr i} {
        set x [lindex $xs $i]
        set w [dict get $cost $x]
        if {$min < 0 || $w < $min} {
            set min $w
            set mini $i
        }
    }
    set x [lindex $xs $mini]
    set xs [lreplace $xs $mini $mini ]
    return $x
}

proc shortestPath {from to} {
    set from [list $from {}]
    set queue [list $from]
    set cost [dict create $from 0]
    set visited [dict create]
    set count 0
    # set path($from) {}
    while {$queue != {}} {
        set p0 [popSmallest queue $cost]
        if {[dict exists $visited $p0]} {
            continue
        }
        puts [incr count]
        set w0 [dict get $cost $p0]
        foreach pw [adjacent $p0] {
            lassign $pw p w
            if {[dict exists $visited $p]} {
                continue
            }
            if {![dict exists $cost $p] || $w0 + $w < [dict get $cost $p]} {
                dict set cost $p [expr {$w0 + $w}]
                lappend queue $p
                if {[lindex $p 0] == $to} {puts "$p -> [dict get $cost $p]"}
                # set path($p) [concat $path($p0) [lindex $p 1]]
            }
        }
        dict set visited $p0 1
    }
    set min -1
    dict for {p d} [dict filter $cost key "{$to} *"] {
        if {$min < 0 || $d < $min} {
            set min $d
            # set best $path($p)
        }
    }
    # puts $best
    return $min
}

set map [lmap line [readLines adv17.txt] {split $line ""}]
set size [expr {[llength $map] - 1}]
puts [shortestPath {0 0} [list $size $size]]
