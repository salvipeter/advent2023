# Is `c` contained in `str` in the `[from, before)` interval?
proc inRange {c str from before} {
    set i [string first $c $str $from]
    expr {$i >= 0 && $i < $before}
}

# Try to locate the `n` > 0 good springs
# Assumption: first `len` characters are OK
proc tryAndCount {springs groups n len} {
    global cache
    set index [list $len $groups]
    if {[dict exists $cache $index]} {
        return [dict get $cache $index]
    }
    set result 0
    if {$groups == {}} {
        set result [expr {[string first # $springs $len] < 0 ? 1 : 0}]
    } else {
        set rest [lassign $groups g]
        for {set k 0} {$k <= $n} {incr k} {
            set d1 [expr {$len+$k}]
            if {[inRange # $springs $len $d1]} {
                break
            }
            set d2 [expr {$d1+$g}]
            if {[inRange . $springs $d1 $d2]} {
                continue
            }
            if {$k == $n} {
                incr result [expr {$rest == {} ? 1 : 0}]
            } elseif {[string index $springs $d2] != "#"} {
                incr d2
                incr result [tryAndCount $springs $rest [expr {$n-$k-1}] $d2]
            }
        }
    }
    dict set cache $index $result
    return $result
}

proc arrangements line {
    global cache part2
    set cache [dict create]
    set springs [lindex $line 0]
    set groups [split [lindex $line 1] ,]
    if {$part2} {
        set springs [join [lrepeat 5 $springs] ?]
        set groups [lrepeat 5 {*}$groups]
    }
    set len [string length $springs]
    set sum 0
    foreach g $groups {
        incr sum $g
    }
    tryAndCount $springs $groups [expr {$len-$sum}] 0
}

set sum 0
foreach line [readLines adv12.txt] {
    incr sum [arrangements $line]
}
puts $sum
