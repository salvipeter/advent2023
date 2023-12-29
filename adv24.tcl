# Notes on Part 2
#
# We need to find point `p` and direction `d`, s.t.
#
#   p + d ti = pi + di ti,
#
# where (pi,di) are the hailstones (i = 1..n).
# The big assumption here is that ti > 0 are all integers.
#
# In other words,
#
#   p = pi + (di - d) ti,
#
# so all coordinates of `p` and `pi` have the same remainders modulo `(di - d)`.
#
# This is satisfied only by one set of coordinates (-20, -274, 31).
# (I assume this in the code, but checked in a reasonable range.)
#
# Now we only need to find `p`, which is the intersection
# of any two lines of the form (pi, di - d).

proc add {u v} {
    lassign $u ux uy uz
    lassign $v vx vy vz
    list [expr {$ux+$vx}] [expr {$uy+$vy}] [expr {$uz+$vz}]
}

proc sub {u v} {
    lassign $u ux uy uz
    lassign $v vx vy vz
    list [expr {$ux-$vx}] [expr {$uy-$vy}] [expr {$uz-$vz}]
}

proc mul {u m} {
    lassign $u ux uy uz
    list [expr {$ux*$m}] [expr {$uy*$m}] [expr {$uz*$m}]
}

proc div {u m} {
    lassign $u ux uy uz
    list [expr {$ux/$m}] [expr {$uy/$m}] [expr {$uz/$m}]
}

proc dot {u v} {
    lassign $u ux uy uz
    lassign $v vx vy vz
    expr {$ux*$vx+$uy*$vy+$uz*$vz}
}

proc sqrnorm u {dot $u $u}

proc insideXY {p min max} {
    lassign $p px py
    expr {$min <= $px && $px <= $max && $min <= $py && $py <= $max}
}

# In Part 1 return if there is an intersection in (min,max)
# In Part 2 return the intersection point or {}
proc intersect {a b min max} {
    global part2
    lassign $a ap ad
    lassign $b bp bd
    set a [dot $ad $ad]
    set b [dot $ad $bd]
    set c [dot $bd $bd]
    set d [dot $ad [sub $ap $bp]]
    set e [dot $bd [sub $ap $bp]]
    set denom [expr {$a*$c-$b*$b}]
    set at [expr {$b*$e-$c*$d}]
    set bt [expr {$a*$e-$b*$d}]
    # Intersection: ap + ad * (at / denom) = bp + bd * (bt / denom)
    if {$denom == 0 || (!$part2 && $at < 0) || $bt < 0} {
        # Parallel (assuming different lines), or not in the future
        return [expr {$part2 ? {} : false}]
    }
    set aint [add [mul $ap $denom] [mul $ad $at]]
    set bint [add [mul $bp $denom] [mul $bd $bt]]
    if {$part2} {
        # In 3D there may not be an intersection at all
        if {$aint == $bint} {
            return [div $aint $denom]
        } else {
            return {}
        }
    }
    set min [expr {$min*$denom}]
    set max [expr {$max*$denom}]
    expr {[insideXY $aint $min $max] && [insideXY $bint $min $max]}
}

proc checkCoord {i di} {
    global hail
    foreach h $hail {
        lassign $h p d
        set r [expr {[lindex $d $i] - $di}]
        if {$r == 0} {
            continue
        }
        set x [expr {[lindex $p $i] % $r}]
        if {[info exists rem($r)] && $rem($r) != $x} {
            return false
        }
        set rem($r) $x
    }
    return true
}

proc findPos dir {
    global hail
    lassign [lindex $hail 0] p1 d1
    lassign [lindex $hail 1] p2 d2
    intersect [list $p1 [sub $d1 $dir]] [list $p2 [sub $d2 $dir]] {} {}
}

set hail {}
foreach line [readLines adv24.txt] {
    regsub -all {[, @]+} $line " " line
    lappend hail [list [lrange $line 0 2] [lrange $line 3 5]]
    if {!$part2} {
        lset hail end 0 2 0
        lset hail end 1 2 0
    }
}

if {$part2} {
    set count 0
    for {set size 0} true {incr size} {
        for {set i 0} {$i < 3} {incr i} {
            if {[info exists found($i)]} {
                continue
            }
            if {[checkCoord $i $size]} {
                set found($i) $size
                incr count
            } elseif {[checkCoord $i -$size]} {
                set found($i) -$size
                incr count
            }
        }
        if {$count == 3} {
            break
        }
    }
    set d [list $found(0) $found(1) $found(2)]
    set p [findPos $d]
    puts [expr {[lindex $p 0]+[lindex $p 1]+[lindex $p 2]}]
} else {
    set min 200000000000000
    set max 400000000000000
    set count 0
    set n [llength $hail]
    for {set i 0} {$i < $n} {incr i} {
        set hail1 [lindex $hail $i]
        for {set j [expr {$i+1}]} {$j < $n} {incr j} {
            set hail2 [lindex $hail $j]
            if {[intersect $hail1 $hail2 $min $max]} {
                incr count
            }
        }
    }
    puts $count
}
