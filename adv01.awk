BEGIN { split("zero one two three four five six seven eight nine", nums) }
{   # use -v part=2 for Part 2
    d1 = ""
    for (j = 1; j <= length($0); j++) {
        s = substr($0, j)
        for (i = 0; i <= 9; i++)
            if (s ~ "^" (part == 2 ? "(" i "|" nums[i+1] ")" : i))
                break
        if (i < 10) {
            if (d1 == "")
                d1 = i
            d2 = i
        }
    }
    sum += d1 * 10 + d2
}
END { print sum }
