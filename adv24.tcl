source readlines.tcl
set part2 true

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
    set min [expr {$min*$denom}]
    set max [expr {$max*$denom}]
    expr {[insideXY $aint $min $max] && [insideXY $bint $min $max]}
}

proc inside {point halfspace} {
    lassign $halfspace p d
    expr {[dot [sub $point $p] $d] > 0}
}

# Find the first sub-octree that is on the "future" side of each hailstone,
# and hope that there will only be one such position.
proc findPos {hail a b} {
    if {$a == $b} {
        return {}
    }
    if {$hail == {}} {
        return [list $a $b]
    }
    set rest [lassign $hail h]
    lassign $a ax ay az
    lassign $b bx by bz
    set vertices [list \
        [list $ax $ay $az] \
        [list $ax $ay $bz] \
        [list $ax $by $az] \
        [list $ax $by $bz] \
        [list $bx $ay $az] \
        [list $bx $ay $bz] \
        [list $bx $by $az] \
        [list $bx $by $bz]]
    set any false
    set all true
    foreach v $vertices {
        if {[inside $v $h]} {
            set any true
            if {!$all} {
                break
            }
        } else {
            set all false
            if {$any} {
                break
            }
        }
    }
    if {$all} {
        tailcall findPos $rest $a $b
    }
    if {!$any} {
        return {}
    }
    set c [div [add $a $b] 2]
    lassign $c cx cy cz
    set divisions [list \
        [list [list $ax $ay $az] [list $cx $cy $cz]] \
        [list [list $cx $ay $az] [list $bx $cy $cz]] \
        [list [list $ax $cy $az] [list $cx $by $cz]] \
        [list [list $cx $cy $az] [list $bx $by $cz]] \
        [list [list $ax $ay $cz] [list $cx $cy $bz]] \
        [list [list $cx $ay $cz] [list $bx $cy $bz]] \
        [list [list $ax $cy $cz] [list $cx $by $bz]] \
        [list [list $cx $cy $cz] [list $bx $by $bz]]]
    foreach sub $divisions {
        if {$sub == [list $a $b]} {
            continue
        }
        set result [findPos $hail {*}$sub]
        if {$result != {}} {
            return $result
        }
    }
    return {}
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

if {$part2} {
    set min 1000000000000
    set max 1000000000000000
    lassign [findPos $hail [list $min $min $min] [list $max $max $max]] a b
    puts "$a --- $b"
} else {
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
