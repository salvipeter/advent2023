proc decide {part rules {rule in}} {
    if {$rule == "A"} {return true}
    if {$rule == "R"} {return false}
    lassign $part x m a s
    foreach condition [dict get $rules $rule] {
        lassign $condition p r
        if {$r == {}} {
            tailcall decide $part $rules $p
        }
        if [string cat \$ $p] {
            tailcall decide $part $rules $r
        }
    }
}

proc rating part {
    set sum 0
    foreach xmas $part {
        incr sum $xmas
    }
    return $sum
}

# Narrow the 4D interval by the given predicate.
# Return `{true-interval false-interval}`.
proc narrow {interval pred} {
    set i [string first [string index $pred 0] xmas]
    set n [string range $pred 2 end]
    lassign [lindex $interval $i] l h
    set ti $interval; set fi $interval
    if {[string index $pred 1] eq "<"} {
        lset ti $i [list $l [expr {$n-1}]]
        lset fi $i [list $n $h]
    } else {
        lset ti $i [list [expr {$n+1}] $h]
        lset fi $i [list $l $n]
    }
    list $ti $fi
}

# Normalize a list of 4D intervals by deleting null-intervals
# (Turns out this is not needed because there is no chain of
#  rules leading to invalid intervals - but there could have been.)
proc normalize intervals {
    set result {}
    foreach int $intervals {
        set ok true
        foreach lh $int {
            lassign $lh l h
            if {$l > $h} {
                set ok false
                break
            }
        }
        if {$ok} {
            lappend result $int
        }
    }
    return $result
}

# Returns a list of distinct non-null intervals
proc combinations {rules interval {rule in}} {
    if {$rule == "A"} {return [list $interval]}
    if {$rule == "R"} {return {}}
    set result {}
    foreach condition [dict get $rules $rule] {
        lassign $condition p r
        if {$r == {}} {
            set narrowed $interval
            set r $p
        } else {
            lassign [narrow $interval $p] narrowed interval
        }
        set result [concat $result [combinations $rules $narrowed $r]]
    }
    normalize $result
}

proc size interval {
    set result 1
    foreach int $interval {
        lassign $int l h
        set result [expr {$result * ($h-$l+1)}]
    }
    return $result
}

set lines [readLines adv19.txt]
set i [lsearch $lines {}]
set rules [dict create]
lmap rule [lrange $lines 0 [expr {$i-1}]] {
    set j [string first \{ $rule]
    set name [string range $rule 0 [expr {$j-1}]]
    dict set rules $name {}
    foreach condition [split [string range $rule [expr {$j+1}] end-1] ,] {
        dict lappend rules $name [split $condition :]
    }
}
set parts [lmap part [lrange $lines [expr {$i+1}] end] {
    set result {}
    foreach xmas [split [string range $part 1 end-1] ,] {
        lappend result [string range $xmas 2 end]
    }
    set result
}]

# Part 1
set sum 0
foreach part $parts {
    if {[decide $part $rules]} {
        incr sum [rating $part]
    }
}
puts $sum

# Part 2
set interval [lrepeat 4 {1 4000}]
set sum 0
foreach interval [combinations $rules $interval] {
    incr sum [size $interval]
}
puts $sum
