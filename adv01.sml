val part = 1

fun toDigit s =
    let val c = String.sub (s, 0)
    in if Char.isDigit c
       then SOME (ord c - ord #"0")
       else if part = 1 then NONE
       else let val numbers =
                    Vector.fromList ["zero","one","two","three","four",
                                     "five","six","seven","eight","nine"]
                fun f (_,n) = String.isPrefix n s
            in (Option.map #1 o Vector.findi f) numbers end
    end

fun extractNumber s =
    let fun f i = toDigit (String.extract (s, i, NONE))
    in let val digits = List.tabulate (size s, f)
           fun either (a, b) = if isSome b then b else a
       in (valOf o foldl either NONE) digits * 10 +
          (valOf o foldr either NONE) digits
       end
    end

val lines =
    let val f = TextIO.openIn "adv01.txt"
    in (String.tokens Char.isSpace o TextIO.inputAll) f
       before TextIO.closeIn f
    end

val answer = (foldl op + 0 o map extractNumber) lines
