set debugOutput false

# Returns the character at the given position,
# or the empty string for invalid positions.
proc pipe {x y} {
    global map
    string index [lindex $map $y] $x
}

# Sets the wall character `c` at the given position.
proc wall {x y c} {
    global walls
    lset walls $y [string replace [lindex $walls $y] $x $x $c]
}

# Steps away from `pos`, but not to `prev`.
# If `check` is false, it does not test the starting position shape.
proc step {pos prev {check true}} {
   set dirs {{-1 0 FL- J7-} {0 -1 7F| LJ|} {1 0 J7- FL-} {0 1 LJ| 7F|}}
   lassign $pos x y
   set c [pipe $x $y]
   foreach dir $dirs {
       lassign $dir dx dy to from
       if {$check && [string first $c $from] < 0} {
           continue
       }
       set pos2 [list [expr {$x+$dx}] [expr {$y+$dy}]]
       if {[set c2 [pipe {*}$pos2]] == ""} {
           continue
       }
       if {$pos2 != $prev && [string first $c2 $to] >= 0} {
           wall {*}$pos2 $c2
           return $pos2
       }
   }
}

set map [readLines adv10.txt]
set walls [lmap line $map {regsub -all . $line .}]
set y 0
while {[set x [string first S [lindex $map $y]]] < 0} {
    incr y
}
set start [list $x $y]

wall {*}$start |; # manual inspection
set prev1 $start
set prev2 $start
set pos1 [step $start {} false]
set pos2 [step $start $pos1 false]
for {set count 1} {$pos1 != $pos2} {incr count} {
    lassign [list $pos1 [step $pos1 $prev1]] prev1 pos1
    lassign [list $pos2 [step $pos2 $prev2]] prev2 pos2
}
puts $count

# Part 2 
set count 0
foreach line $walls {
    set inside false
    foreach c [split $line ""] {
        switch $c {
            F {set pair 7}
            L {set pair J}
            7 {if {$pair ne "7"} {set inside [expr {!$inside}]}}
            J {if {$pair ne "J"} {set inside [expr {!$inside}]}}
            | {set inside [expr {!$inside}]}
            . {if {$inside} {incr count}}
        }
        if {$debugOutput} {
            puts -nonewline [expr {$inside && $c eq "." ? "x" : $c}]
        }
    }
    if {$debugOutput} {
        puts ""
    }
}
puts $count
