proc seedify seeds {
    return [lmap x $seeds {list $x 1}]; # comment for Part 2
    set result {}
    for {set i 0} {$i < [llength $seeds]} {incr i 2} {
        lappend result [lrange $seeds $i [expr {$i+1}]]
    }
    return $result
}

proc convert {rules old newname} {
    upvar $newname new
    lassign $rules dest src len
    set rest {}
    foreach v $old {
        lassign $v x xlen
        if {$x < $src && $x+$xlen >= $src} {
            set xend [expr {min($x+$xlen,$src+$len)}]
            lappend new [list $dest [expr {$xend-$src}]]
            lappend rest [list $x [expr {$src-$x}]]
        } elseif {$x >= $src && $x+$xlen <= $src+$len} {
            lappend new [list [expr {$x-$src+$dest}] $xlen]
        } elseif {$x < $src+$len && $x+$xlen > $src+$len} {
            lappend new [list [expr {$x-$src+$dest}] [expr {$src+$len-$x}]]
            lappend rest [list [expr {$src+$len}] [expr {$x-($src+$len)}]]
        } else {
            lappend rest $v
        }
    }
    return $rest
}

set f [open adv05.txt]
set line [gets $f]
set x [seedify [lrange $line 1 end]]
gets $f; # empty line
gets $f; # header

set y {}
while true {
    set line [gets $f]
    if {[eof $f]} {
        close $f
        set x [concat $x $y]
        break
    }
    if {$line == ""} {
        set x [concat $x $y]
        set y {}
        gets $f; # header
    } else {
        set x [convert $line $x y]
    }
}
puts [lindex [lsort -integer [lmap n $x {lindex $n 0}]] 0]

