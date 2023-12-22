# For visualization - input is assumed to be lines of x1 y1 z1 x2 y2 z2
BEGIN { d = 0.5; xshift = 0 }
{
    if ($1 != $4) {
        # x-cuboid
        print "v", $1 + xshift - d, $2 - d, $3 - d
        print "v", $1 + xshift - d, $2 - d, $3 + d
        print "v", $1 + xshift - d, $2 + d, $3 + d
        print "v", $1 + xshift - d, $2 + d, $3 - d
        print "v", $4 + xshift + d, $5 - d, $6 - d
        print "v", $4 + xshift + d, $5 - d, $6 + d
        print "v", $4 + xshift + d, $5 + d, $6 + d
        print "v", $4 + xshift + d, $5 + d, $6 - d
    } else if ($2 != $5) {
        # y-cuboid
        print "v", $1 + xshift + d, $2 - d, $3 - d
        print "v", $1 + xshift + d, $2 - d, $3 + d
        print "v", $1 + xshift - d, $2 - d, $3 + d
        print "v", $1 + xshift - d, $2 - d, $3 - d
        print "v", $4 + xshift + d, $5 + d, $6 - d
        print "v", $4 + xshift + d, $5 + d, $6 + d
        print "v", $4 + xshift - d, $5 + d, $6 + d
        print "v", $4 + xshift - d, $5 + d, $6 - d
    } else {
        # z-cuboid
        print "v", $1 + xshift - d, $2 - d, $3 - d
        print "v", $1 + xshift - d, $2 + d, $3 - d
        print "v", $1 + xshift + d, $2 + d, $3 - d
        print "v", $1 + xshift + d, $2 - d, $3 - d
        print "v", $4 + xshift - d, $5 - d, $6 + d
        print "v", $4 + xshift - d, $5 + d, $6 + d
        print "v", $4 + xshift + d, $5 + d, $6 + d
        print "v", $4 + xshift + d, $5 - d, $6 + d
    }
    print "f", n + 1, n + 2, n + 3, n + 4
    print "f", n + 5, n + 8, n + 7, n + 6
    print "f", n + 4, n + 8, n + 5, n + 1
    print "f", n + 1, n + 5, n + 6, n + 2
    print "f", n + 2, n + 6, n + 7, n + 3
    print "f", n + 3, n + 7, n + 8, n + 4
    n += 8
}
