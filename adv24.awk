# For visualization - change `s` to modify the ray lengths
BEGIN { FS = "[, @]+"; s = 1000000000000.0 }
{
    x = $1 / s; y = $2 / s; z = $3 / s
    print "v", x, y, z
    print "v", x + $4, y + $5, z + $6
    print "p", NR * 2 - 1
    print "l", NR * 2 - 1, NR * 2
}
