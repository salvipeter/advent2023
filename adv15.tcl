proc hash s {
    set h 0
    for {set i 0} {$i < [string length $s]} {incr i} {
        scan [string index $s $i] %c d
        set h [expr {($h + $d) * 17 % 256}]
    }
    return $h
}

proc power boxes {
    set sum 0
    for {set i 0} {$i <= 255} {incr i} {
        set j 1
        foreach lens [dict get $boxes $i] {
            incr sum [expr {($i + 1) * $j * [lindex $lens 1]}]
            incr j
        }
    }
    return $sum
}

set lines [split [readLines adv15.txt] ,]
set boxes [dict create]
for {set i 0} {$i <= 255} {incr i} {
    dict set boxes $i {}
}

set sum 0
foreach cmd $lines {
    incr sum [hash $cmd]
    if {[string index $cmd end] eq "-"} {
        set lens [string range $cmd 0 end-1]
        set box [hash $lens]
        set contents [dict get $boxes $box]
        set index [lsearch $contents "$lens ?"]
        if {$index >= 0} {
            dict set boxes $box [lreplace $contents $index $index]
        }
    } else {
        lassign [split $cmd =] lens focal
        set box [hash $lens]
        set contents [dict get $boxes $box]
        set index [lsearch $contents "$lens ?"]
        set new [list $lens $focal]
        if {$index >= 0} {
            dict set boxes $box [lreplace $contents $index $index $new]
        } else {
            lappend contents $new
            dict set boxes $box $contents
        }
    }
}
puts "$sum [power $boxes]"
