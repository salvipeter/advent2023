val part = ref 1

fun extrapolate xs =
  if List.all (fn x => x = 0) xs then 0 else
    if !part = 1 then
      hd (rev xs) + extrapolate (ListPair.map op - (tl xs, xs))
    else
      hd xs - extrapolate (ListPair.map op - (tl xs, xs))

fun parse line =
    let val ss = String.tokens Char.isSpace line
    in map (valOf o LargeInt.fromString) ss end

val lines =
  let val f = TextIO.openIn "adv09.txt" in
    let fun loop acc = case TextIO.inputLine f of
                            NONE   => ( TextIO.closeIn f ; rev acc )
                          | SOME s => loop (parse s :: acc)
  in loop [] end end 

fun answer p = ( part := p; (foldl op + 0 o map extrapolate) lines )
