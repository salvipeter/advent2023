# More ideas:
#
# - the p + d t line intersects line i if
#   - p + d ti = pi + di ti
#   - (d x di) (p - pi) = 0
#   - d, di & (p - pi) are coplanar (their matrix has det = 0)
#   (these do not check if ti > 0)
# - number theoretic approach (Chinese remainder theorem ...?)
#   - assuming that time is also integral
# - try an endless iteration of possible directions
#   - if the direction is fixed, the position can be computed
#     by a linear system of equations
#   - the possible (integral) directions can be ordered by length
source readlines.tcl
set part2 true
package require math::linearalgebra

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

proc findPos {hail dir} {
    set n [llength $hail]
    set A [math::linearalgebra::mkMatrix [expr {$n*3}] [expr {$n+3}] 0]
    set b [math::linearalgebra::mkVector [expr {$n*3}] 0]
    for {set i 0} {$i < $n} {incr i} {
        lassign [lindex $hail $i] p d
        set d [sub $dir $d]
        for {set j 0} {$j < 3} {incr j} {
            set row [expr {$i*3+$j}]
            math::linearalgebra::setelem A $row $j 1
            math::linearalgebra::setelem A $row [expr {$i+3}] [lindex $d $j]
            math::linearalgebra::setelem b $row [lindex $p $j]
        }
    }
    set x [math::linearalgebra::leastSquaresSVD $A $b]
    set p [list \
        [math::linearalgebra::getelem $x 0] \
        [math::linearalgebra::getelem $x 1] \
        [math::linearalgebra::getelem $x 2]]
    puts $p
    set pi [lmap x $p {expr {round($x)}}]
    expr {[sqrnorm [sub $p $pi]] < 1e-5 ? $pi : {}}
}

set hail {}
foreach line [readLines adv24t.txt] {
    regsub -all {[, @]+} $line " " line
    lappend hail [list [lrange $line 0 2] [lrange $line 3 5]]
    if {!$part2} {
        lset hail end 0 2 0
        lset hail end 1 2 0
    }
}

if {$part2} {
    for {set size 1} true {incr size} {
        puts "$size..."
        for {set x 0} {$x <= $size} {incr x} {
            for {set y 0} {$y <= $size - $x} {incr y} {
                set d [list $x $y [expr {$size - $x - $y}]]
                for {set sign 0} {$sign < 8} {incr sign} {
                    if {$sign & 1} {lset d 0 [expr {-[lindex $d 0]}]}
                    if {$sign & 2} {lset d 1 [expr {-[lindex $d 1]}]}
                    if {$sign & 4} {lset d 2 [expr {-[lindex $d 2]}]}
                    set p [findPos $hail $d]
                    if {$p != {}} {
                        puts [expr {[lindex $p 0]+[lindex $p 1]+[lindex $p 2]}]
                        exit
                    }
                }
            }
        }
    }
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
