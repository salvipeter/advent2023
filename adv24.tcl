source readlines.tcl
set part2 true

# Idea: take the intersection of all halfspaces,
# and hopefully there will be only one integer position inside

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

proc insideXY {p min max} {
    lassign $p px py
    expr {$min <= $px && $px <= $max && $min <= $py && $py <= $max}
}

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
        return false
    }
    set aint [add [mul $ap $denom] [mul $ad $at]]
    set bint [add [mul $bp $denom] [mul $bd $bt]]
    if {$part2} {
        # In 3D there may not be an intersection at all
        return [expr {$aint == $bint}]
    }
    set min [expr {$min*$denom}]
    set max [expr {$max*$denom}]
    expr {[insideXY $aint $min $max] && [insideXY $bint $min $max]}
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
set n [llength $hail]

if {$part2} {
    # Assume that the first two hailstones meet the stone at integer times
    lassign [lindex $hail 0] p1 d1
    lassign [lindex $hail 1] p2 d2
    set found false
    for {set k 2} {!$found} {incr k} {
        puts "$k..."
        for {set i 1} {$i < $k} {incr i} {
            set j [expr {$k-$i}]
            set q1 [add $p1 [mul $d1 $i]]
            set q2 [add $p2 [mul $d2 $j]]
            set d [sub $q1 $q2]
            set found true
            for {set h 2} {$h < $n} {incr h} {
                if {![intersect [list $q1 $d] [lindex $hail $h] {} {}]} {
                    set found false
                    if {$h>2} {puts "($h)"}
                    break
                }
            }
            if {$found} {
                puts "$i $j"
                set q [sub $q1 [div [mul $d $i] [expr {abs($j-$i)}]]]
                puts "Found: $q"
                lassign $q x y z
                puts [expr {$x+$y+$z}]
                break
            }
        }
    }
} else {
    set min 200000000000000
    set max 400000000000000
    set count 0
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
