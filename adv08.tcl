proc step {from count} {
    global map moves
    set len [string length $moves]
    set move [string index $moves [expr {$count % $len}]]
    lindex [dict get $map $from] [expr {$move=="L" ? 0 : 1}]
}

proc gcd {a b} {
    while {$b != 0} {
        set b [expr {$a % [set a $b]}]
    }
    return $a
}

proc lcm {a b} {expr {$a*$b/[gcd $a $b]}}

set lines [readLines adv08.txt]
set moves [lindex $lines 0]
set map [dict create]
foreach line [lrange $lines 2 end] {
    set pair [list [string range $line 7 9] [string range $line 12 14]]
    dict set map [string range $line 0 2] $pair
}

# Implicit assumption: after the first ..Z each path cycles back
foreach from [dict keys $map] {
    if {[string index $from 2] != "A"} {
        continue
    }
    set count 0
    set pos $from
    while {[string index $pos 2] != "Z"} {
        set pos [step $pos $count]
        incr count
    }
    set path($from) $count
}

set len 1
foreach pos [array names path] {
    set len [lcm $len $path($pos)]
}
puts "$path(AAA), $len"


