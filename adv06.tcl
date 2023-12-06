proc waysToWin {t d} {
    # x^2 - t x + d = 0
    set D [expr {sqrt($t*$t-4*$d)}]
    set x1 [expr {int(ceil(($t-$D)/2))}]
    set x2 [expr {int(($t+$D)/2)}]
    expr {$x2-$x1+1}
}

set f [open adv06.txt]
set times [lrange [gets $f] 1 end]
set distances [lrange [gets $f] 1 end]
close $f

set result 1
foreach t $times d $distances {
    set result [expr {$result*[waysToWin $t $d]}]
}
puts $result
puts [waysToWin [join $times ""] [join $distances ""]]
