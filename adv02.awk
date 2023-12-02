BEGIN { FS = "[:,; ]*"; n["red"] = 12; n["green"] = 13; n["blue"] = 14 }
{   # use -v part=2 for Part 2
    if (part == 2)
        delete n
    i = 3
    while (i < NF)
        for (j = 1; j <= 3; j++) {
            if ($i > n[$(i+1)]) {
                if (part != 2)
                    next
                n[$(i+1)] = $i
            }
            i += 2
        }
    sum += part == 2 ? n["red"] * n["green"] * n["blue"] : $2
}
END { print sum }
