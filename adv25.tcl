source readlines.tcl

proc select xs {
    set n [llength $xs]
    set k [expr {int(rand()*$n)}]
    lindex $xs $k
}

proc karger {nodes edges} {
    set n [llength $nodes]
    while {$n > 2} {
        incr n -1
        lassign [select $edges] a b
        set ai -1; set bi -1
        for {set i 0} {$i <= $n} {incr i} {
            set node [lindex $nodes $i]
            if {[lsearch $node $a] >= 0} {set ai $i}
            if {[lsearch $node $b] >= 0} {set bi $i}
            if {$ai >= 0 && $bi >= 0} break
        }
        set node [concat [lindex $nodes $ai] [lindex $nodes $bi]]
        set nodes [lreplace $nodes $ai $ai $node]
        set nodes [lreplace $nodes $bi $bi]
        set edges2 {}
        foreach e $edges {
            lassign $e x y
            if {[lsearch $node $x] < 0 || [lsearch $node $y] < 0} {
                lappend edges2 $e
            }
        }
        set edges $edges2
    }
    list $nodes $edges
}

set edges {}
foreach line [readLines adv25.txt] {
    set a [string range [lindex $line 0] 0 end-1]
    foreach b [lrange $line 1 end] {
        lappend edges [list $a $b]
    }
}
set nodes [lsort -unique [concat {*}$edges]]

while true {
    puts -nonewline .; flush stdout
    lassign [karger $nodes $edges] groups cut
    if {[llength $cut] == 3} {
        lassign $groups a b
        puts [expr {[llength $a] * [llength $b]}]
        break
    }
}
