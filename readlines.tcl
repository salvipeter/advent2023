proc readLines filename {
    set f [open $filename]
    set result [split [read -nonewline $f] "\n"]
    close $f
    return $result
}
