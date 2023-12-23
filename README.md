# Advent of Code 2023 Solutions

To enhance its "retro" feel, I decided to solve this year's
problems on a 15-year-old old laptop (an AsusTek 1000HE, single
core 1.6 GHz CPU, 800 MB RAM), with a 32-bit Alpine Linux
installed, but without X11 - only in text mode. Not 80x25
though, but 102x33, using the 18pt bold Terminus console font.

The only tools used are `links` (to access the problems), `vim`
(to write the code), `tcl` (to run the code), and `rlwrap` (for
a bit of comfort in `tclsh`).

To run the Tcl solutions, you need to first source
`readlines.tcl`, and define a global Boolean variable `part2`,
which is `false` for Part 1 and `true` for Part 2. Or just use
the `run` script.

Some solutions were quite slow and were translated into a
statically typed compiled language (SML or C/C++), see the
[Hall of Shame](hall-of-shame.txt).
