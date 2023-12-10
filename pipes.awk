BEGIN {
    FS = ""
    size = 140
    cell = 4
    print "<svg xmlns='http://www.w3.org/2000/svg'" \
              " width='" cell * size "' height='" cell * size "'>"
}
{
    x = 0
    for (i = 1; i <= NF; i++) {
        switch($i) {
        case "|":
            print "<line x1='" x + cell/2 "' y1='" y "'" \
                       " x2='" x + cell/2 "' y2='" y + cell "'" \
                       " stroke='black' stroke-width='2'/>"
            break
        case "-":
            print "<line x1='" x "' y1='" y + cell/2 "'" \
                       " x2='" x + cell "' y2='" y + cell/2 "'" \
                       " stroke='black' stroke-width='2'/>"
            break
        case "J":
            print "<line x1='" x "' y1='" y + cell/2 "'" \
                       " x2='" x + cell/2 "' y2='" y + cell/2 "'" \
                       " stroke='black' stroke-width='2'/>"
            print "<line x1='" x + cell/2 "' y1='" y + cell/2 "'" \
                       " x2='" x + cell/2 "' y2='" y "'" \
                       " stroke='black' stroke-width='2'/>"
            break
        case "F":
            print "<line x1='" x + cell "' y1='" y + cell/2 "'" \
                       " x2='" x + cell/2 "' y2='" y + cell/2 "'" \
                       " stroke='black' stroke-width='2'/>"
            print "<line x1='" x + cell/2 "' y1='" y + cell/2 "'" \
                       " x2='" x + cell/2 "' y2='" y + cell "'" \
                       " stroke='black' stroke-width='2'/>"
            break
        case "L":
            print "<line x1='" x + cell "' y1='" y + cell/2 "'" \
                       " x2='" x + cell/2 "' y2='" y + cell/2 "'" \
                       " stroke='black' stroke-width='2'/>"
            print "<line x1='" x + cell/2 "' y1='" y + cell/2 "'" \
                       " x2='" x + cell/2 "' y2='" y "'" \
                       " stroke='black' stroke-width='2'/>"
            break
        case "7":
            print "<line x1='" x "' y1='" y + cell/2 "'" \
                       " x2='" x + cell/2 "' y2='" y + cell/2 "'" \
                       " stroke='black' stroke-width='2'/>"
            print "<line x1='" x + cell/2 "' y1='" y + cell/2 "'" \
                       " x2='" x + cell/2 "' y2='" y + cell "'" \
                       " stroke='black' stroke-width='2'/>"
            break
        case "x":
            print "<rect x='" x "' y='" y "'" \
                       " width='" cell "' height='" cell "'"  \
                       " fill='blue' />"
        }
        x += cell
    }
    y += cell
}
END {
    print "</svg>"
}
