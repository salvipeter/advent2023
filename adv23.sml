val part = ref 1

val map =
    let val f = TextIO.openIn "adv23.txt"
    in let fun loop acc = 
               case TextIO.inputLine f of
                   NONE   => ( TextIO.closeIn f
                             ; (Vector.fromList o rev) acc
                             )
                 | SOME s => loop (s :: acc)
       in loop [] end
    end

val size = Vector.length map

fun get (x, y) =
    if x < 0 orelse y < 0 orelse x >= size orelse y >= size then
        NONE
    else
        SOME (String.sub (Vector.sub (map, y), x))

fun adjacent (x, y) =
    let val terrain = (valOf o get) (x, y)
        val dirs = [(0,~1,#"^"),(1,0,#">"),(0,1,#"v"),(~1,0,#"<")]
        fun try (dx, dy, slope) =
            if !part = 1 andalso terrain <> #"." andalso terrain <> slope then
                NONE
            else let val pos = (x + dx, y + dy)
                 in case get pos of
                        NONE      => NONE
                      | SOME #"#" => NONE
                      | SOME _    => SOME pos
                 end
    in List.mapPartial try dirs end

type pos = int * int
datatype cross = DeadEnd | Goal of int | Cross of pos * int * pos list

fun crossroads from to prev len =
    if from = to then Goal len else
    let val neighbors = List.filter (fn x => x <> prev) (adjacent from)
    in case length neighbors of
           0 => DeadEnd
         | 1 => crossroads (hd neighbors) to from (len + 1)
         | _ => Cross (from, len + 1, neighbors)
    end

val cache = Array2.array (size, size, NONE)
fun crossroads' from to prev =
    case Array2.sub (cache, #1 from, #2 from) of
        SOME result => result
      | NONE        =>
        let val result = crossroads from to prev 0
        in ( Array2.update (cache, #1 from, #2 from, SOME result)
           ; result
           )
        end

fun longest from to visited =
    let val prev = if null visited then (0,0) else hd visited
    in case crossroads' from to prev of
           DeadEnd                 => NONE
         | Goal n                  => SOME n
         | Cross (from, len, next) =>
           let val found = List.find (fn x => x = from) visited
               fun f path = longest path to (from :: visited)
           in if found = NONE then
                  SOME (len + (foldl Int.max 0 o List.mapPartial f) next)
              else
                  NONE
           end
    end

fun answer p =
    ( part := p
    ; Array2.modify Array2.RowMajor (fn _ => NONE) cache
    ; valOf (longest (1,0) (size-2,size-1) [])
    )
