# Note that:
# - any square reached in `n` steps will also be reached
#   in `m > n` steps if `m` and `n` have the same parity
# - the size of the map is odd, with the gardener at the center
# - there is an empty row/column at the sides
# - the middle row/column is also empty (in contrary to the example!)
# - n := 26501365 (number of steps), k := 131 (size)
# - n % k = 65 = (k-1)/2 =: h, 
#   so going straight in any direction, the Elf exactly reaches
#   the end of a tile in the infinite layout
# - the farthest plot from a corner has distance 260 = 2(k-1),
#   and from an edge midpoint 195 = (k-1) + h, meaning that
#   there is nothing further away than an opposing corner,
#   which can be reached in a trivial way.
# - r = floor(n/k + 0.5) = 202300 is the interesting radius
# - of these, all but the edge is fully contained,
#   which means (r-1)^2 "odd" and r^2 "even" tiles
#   ("odd" means that plots reached by an odd number of steps are counted)
# - of the partial ones, there are 3 types:
#   - side: # of plots reachable by n - (h + k (r - 1) + 1) steps
#           from the middle of one edge (only odds)
#   - corner: # of plots reachable by n - (2h + k (r - 2) + 2) steps
#             from one corner [only odds] * (r - 1)
#   - corner: # of plots reachable by n - (2h + k (r - 1) + 2) steps
#             from one corner [only evens] * r

# The solution below is somewhat specific
# (e.g. assumes that n % 2 == 1 or that r % 2 == 0).

proc get {x y} {
    global map
    string index [lindex $map $y] $x
}

proc step pos {
    set result {}
    foreach dx {0 1 0 -1} dy {-1 0 1 0} {
        lassign $pos x y
        incr x $dx
        incr y $dy
        if {[get $x $y] eq "."} {
            lappend result [list $x $y]
        }
    }
    return $result
}

proc reachable {size from steps} {
    lassign $from x y
    set cost [lrepeat $size [lrepeat $size -1]]
    lset cost $x $y 0
    set changed [list $from]
    while {$changed != {}} {
        set changed [lassign $changed pos]
        lassign $pos x0 y0
        set w0 [lindex $cost $x0 $y0]
        if {$w0 >= $steps} {
            continue
        }
        foreach adj [step $pos] {
            lassign $adj x y
            set w [lindex $cost $x $y]
            if {$w < 0 || $w0 + 1 < $w} {
                lset cost $x $y [expr {$w0 + 1}]
                if {[lsearch $changed $adj] < 0} {
                    lappend changed $adj
                }
            }
        }
    }
    set parity [expr {$steps % 2}]
    set count 0
    for {set x 0} {$x < $size} {incr x} {
        for {set y 0} {$y < $size} {incr y} {
            set w [lindex $cost $x $y]
            if {$w >= 0 && $w % 2 == $parity} {
                incr count
            }
        }
    }
    return $count
}

set map [readLines adv21.txt]
set k [llength $map]
set h [expr {($k-1)/2}]
set start [list $h $h]
lset map $h [string replace [lindex $map $h] $h $h "."]

puts [reachable $k $start 64]
 
# Part 2
set n 26501365 
set m [expr {$k-1}]
set r [expr {$n/$k}]
set evens [reachable $k {0 0} 1000]
set odds [reachable $k {0 0} 1001]
set sum 0
incr sum [expr {($r-1)**2*$odds}]
incr sum [expr {$r**2*$evens}]
set steps [expr {$n - ($h + $k * ($r - 1) + 1)}]
incr sum [reachable $k [list $h 0] $steps]
incr sum [reachable $k [list $h $m] $steps]
incr sum [reachable $k [list 0 $h] $steps]
incr sum [reachable $k [list $m $h] $steps]
set steps [expr {$n - (2 * $h + $k * ($r - 2) + 2)}]
incr sum [expr {($r-1) * [reachable $k [list 0 0] $steps]}]
incr sum [expr {($r-1) * [reachable $k [list 0 $m] $steps]}]
incr sum [expr {($r-1) * [reachable $k [list $m 0] $steps]}]
incr sum [expr {($r-1) * [reachable $k [list $m $m] $steps]}]
set steps [expr {$n - (2 * $h + $k * ($r - 1) + 2)}]
incr sum [expr {$r * [reachable $k [list 0 0] $steps]}]
incr sum [expr {$r * [reachable $k [list 0 $m] $steps]}]
incr sum [expr {$r * [reachable $k [list $m 0] $steps]}]
incr sum [expr {$r * [reachable $k [list $m $m] $steps]}]
puts $sum
