source readlines.tcl
set part2 false

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

proc dot {u v} {
    lassign $u ux uy uz
    lassign $v vx vy vz
    expr {$ux*$vx+$uy*$vy+$uz*$vz}
}

proc insideXY {p min max} {
    lassign $p px py
    expr {$min <= $px && $px <= $max && $min <= $py && $py <= $max}
}

proc intersect {a b {min {}} {max {}}} {
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
    if {$denom == 0 || $at < 0 || $bt < 0} {
        # Parallel (assuming different lines), or not in the future
        return false
    }
    set aint [add [mul $ap $denom] [mul $ad $at]]
    set bint [add [mul $bp $denom] [mul $bd $bt]]
    if {$min == {}} {
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
