val part = ref 1

val lines =
    let val f = TextIO.openIn "adv12.txt"
    in let fun loop acc = 
        case TextIO.inputLine f of
          NONE   => ( TextIO.closeIn f ; rev acc )
        | SOME s => loop (s :: acc)
       in loop [] end
    end

val maxlen = foldl Int.max 0 (map size lines) * 5

val cache = Array2.array (maxlen, maxlen, 0)

fun try springs groups n len =
    let val cached = Array2.sub (cache, n, len)
        fun update x = ( Array2.update (cache, n, len, x) ; x )
    in if cached >= 0 then cached 
       else case List.getItem groups of
              NONE => let val s = String.extract (springs, len, NONE)
                      in update (if String.isSubstring "#" s then 0 else 1) end
            | SOME (g, rest) =>
                let fun f k acc =
                        if k > n then acc
                        else let val d = len + k
                                 val s = substring (springs, len, k)
                             in if String.isSubstring "#" s then acc
                                else let val s = substring (springs, d, g)
                                         val d = d + g
                                     in if String.isSubstring "." s then
                                            f (k + 1) acc
                                        else if k = n then 
                                            if null rest then acc + 1 else acc
                                        else if String.sub (springs, d) <> #"#" then
                                            let val r = try springs rest (n - k - 1) (d + 1)
                                            in f (k + 1) (acc + r) end
                                        else
                                            f (k + 1) acc
                                     end
                             end
                in update (f 0 0) end
    end

fun parse line =
    case String.tokens Char.isSpace line of
      [s, xs] =>
        let fun isComma c = c = #","
            val g = map (valOf o Int.fromString) (String.tokens isComma xs)
            val ss = if !part = 1 then [s] else List.tabulate (5, fn _ => s)
        in let val gs = if !part = 1 then [g] else List.tabulate (5, fn _ => g)
           in (String.concatWith "?" ss, List.concat gs) end
        end
    | _ => raise Fail "invalid data"

fun arrangements line =
    ( Array2.modify Array2.RowMajor (fn _ => ~1) cache
    ; let val (springs, groups) = parse line
      in let val len = size springs
             val sum = foldl op + 0 groups
         in try springs groups (len - sum) 0 end
      end
    )

fun answer p =
    ( part := p
    ; (foldl LargeInt.+ (Int.toLarge 0) o map arrangements) lines
    )
